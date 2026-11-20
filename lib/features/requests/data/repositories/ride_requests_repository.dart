import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../domain/entities/ride_request.dart';

class RideRequestsRepository {
  final SupabaseClient _client;

  RideRequestsRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  /// Creates a ride request
  Future<RideRequest> createRequest({
    required String rideId,
    required String requesterId,
    int seatsRequested = 1,
    String? message,
  }) async {
    final response = await _client
        .from('ride_requests')
        .insert({
          'ride_id': rideId,
          'requester_id': requesterId,
          'seats_requested': seatsRequested,
          'status': 'pending',
          'message': message,
        })
        .select('*, profiles:requester_id(display_name, avatar_url, home_city, id_verified, id_type, id_number_masked)')
        .single();

    final created = RideRequest.fromMap(response);

    // Notify ride owner (driver)
    try {
      final rideData = await _client
          .from('rides')
          .select('owner_id, origin_city, destination_city')
          .eq('id', rideId)
          .single();
      final ownerId = rideData['owner_id'] as String?;
      if (ownerId != null && ownerId != requesterId) {
        await _client.from('notifications').insert({
          'recipient_id': ownerId,
          'notification_type': 'ride_request',
          'reference_id': created.id,
          'title': 'New Ride Request / नया सवारी अनुरोध',
          'body': 'A co-traveler requested $seatsRequested seat(s) for your ${rideData['origin_city']} ➔ ${rideData['destination_city']} journey. (एक सहयात्री ने सवारी का अनुरोध किया है।)',
        });
      }
    } catch (_) {}

    return created;
  }

  /// Fetches requests made by the current user
  Future<List<Map<String, dynamic>>> getMyRequestsWithRide(String userId) async {
    final response = await _client
        .from('ride_requests')
        .select('*, rides(*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked))')
        .eq('requester_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetches incoming requests for a ride owned by the user
  Future<List<RideRequest>> getIncomingRequestsForRide(String rideId) async {
    final response = await _client
        .from('ride_requests')
        .select('*, profiles:requester_id(display_name, avatar_url, home_city, id_verified, id_type, id_number_masked)')
        .eq('ride_id', rideId)
        .order('created_at', ascending: false);

    return (response as List).map((row) => RideRequest.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Fetches a single ride request with full ride & profiles context
  Future<Map<String, dynamic>?> getRequestWithDetails(String requestId) async {
    final response = await _client
        .from('ride_requests')
        .select('*, rides(*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)), profiles:requester_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .eq('id', requestId)
        .maybeSingle();

    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  /// Accepts a request atomically using Supabase RPC
  Future<Map<String, dynamic>> acceptRequest(String requestId) async {
    final response = await _client.rpc(
      'accept_ride_request',
      params: {'p_request_id': requestId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Rejects a request
  Future<void> rejectRequest(String requestId) async {
    await _client.from('ride_requests').update({
      'status': 'rejected',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', requestId);
  }

  /// Cancels a pending request
  Future<void> cancelRequest(String requestId) async {
    await _client.from('ride_requests').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', requestId);
  }

  /// Permanently deletes a ride request.
  /// 1. Notifies the driver that the passenger cancelled their seat.
  /// 2. Restores available seats on the ride if it was already accepted.
  /// 3. Records cancellation in `trip_cancellations` for backend tracking and abuse prevention.
  Future<void> deleteRequest(String requestId) async {
    // 1. Fetch request details to notify driver and restore seats if needed
    Map<String, dynamic>? req;
    try {
      req = await getRequestWithDetails(requestId);
    } catch (e) {
      debugPrint('Notice: Error fetching request details before deletion: $e');
    }

    final ride = req?['rides'] as Map<String, dynamic>?;
    final driverId = ride?['owner_id']?.toString();
    final origin = ride?['origin_city'] ?? 'Origin';
    final dest = ride?['destination_city'] ?? 'Destination';
    final status = req?['status']?.toString();
    final seats = (req?['seats_requested'] as int?) ?? 1;
    final rideId = req?['ride_id']?.toString();

    // 2. Notify driver if request was pending or accepted
    if (driverId != null && (status == 'pending' || status == 'accepted')) {
      try {
        await _client.from('notifications').insert({
          'recipient_id': driverId,
          'notification_type': 'request_cancelled',
          'title': 'Seat Request Cancelled / सीट अनुरोध रद्द',
          'body': 'A passenger cancelled their seat request for the $origin → $dest journey. (यात्री ने अनुरोध रद्द कर दिया है।)',
          'reference_id': rideId,
        });
      } catch (e) {
        debugPrint('Error notifying driver of request cancellation: $e');
      }

      // Restore available seats if accepted
      if (status == 'accepted' && rideId != null) {
        try {
          final currRide = await _client.from('rides').select('available_seats').eq('id', rideId).maybeSingle();
          if (currRide != null) {
            final currAvail = (currRide['available_seats'] as int?) ?? 0;
            await _client.from('rides').update({'available_seats': currAvail + seats}).eq('id', rideId);
          }
        } catch (e) {
          debugPrint('Error restoring ride available seats: $e');
        }
      }
    }

    // 3. Record in trip_cancellations
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId != null) {
      try {
        await _client.from('trip_cancellations').insert({
          'user_id': currentUserId,
          'entity_type': 'ride_request',
          'entity_id': requestId,
          'reason': 'Passenger cancelled ride request',
          'affected_users_count': driverId != null ? 1 : 0,
        });

        final profile = await _client
            .from('profiles')
            .select('cancellation_count')
            .eq('id', currentUserId)
            .maybeSingle();
        final currCount = (profile?['cancellation_count'] as int?) ?? 0;
        await _client.from('profiles').update({
          'cancellation_count': currCount + 1,
        }).eq('id', currentUserId);
      } catch (e) {
        debugPrint('Error recording cancellation in database: $e');
      }
    }

    // 4. Delete the request
    await _client.from('ride_requests').delete().eq('id', requestId);
  }

  /// Fetches ALL incoming requests for any ride owned by this driver
  Future<List<Map<String, dynamic>>> getAllIncomingRequestsForDriver(String driverId) async {
    final response = await _client
        .from('ride_requests')
        .select('*, rides!inner(*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)), profiles:requester_id(display_name, avatar_url, home_city)')
        .eq('rides.owner_id', driverId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetches all active conversation threads for a user (as driver or rider)
  Future<List<Map<String, dynamic>>> getAllConversationsForUser(String userId) async {
    final asRider = await _client
        .from('ride_requests')
        .select('*, rides(*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)), profiles:requester_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .eq('requester_id', userId)
        .order('created_at', ascending: false);

    final asDriver = await _client
        .from('ride_requests')
        .select('*, rides!inner(*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)), profiles:requester_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .eq('rides.owner_id', userId)
        .order('created_at', ascending: false);

    final Map<String, Map<String, dynamic>> uniqueMap = {};
    for (final item in (asRider as List)) {
      final map = Map<String, dynamic>.from(item as Map);
      map['my_role'] = 'rider';
      uniqueMap[map['id']] = map;
    }
    for (final item in (asDriver as List)) {
      final map = Map<String, dynamic>.from(item as Map);
      map['my_role'] = 'driver';
      uniqueMap[map['id']] = map;
    }

    final list = uniqueMap.values.toList();
    list.sort((a, b) {
      final aDate = a['created_at']?.toString() ?? '';
      final bDate = b['created_at']?.toString() ?? '';
      return bDate.compareTo(aDate);
    });

    return list;
  }
}
