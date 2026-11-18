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
        .select('*, profiles:requester_id(display_name, avatar_url, home_city)')
        .single();

    return RideRequest.fromMap(response);
  }

  /// Fetches requests made by the current user
  Future<List<Map<String, dynamic>>> getMyRequestsWithRide(String userId) async {
    final response = await _client
        .from('ride_requests')
        .select('*, rides(*, profiles:owner_id(display_name, avatar_url))')
        .eq('requester_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetches incoming requests for a ride owned by the user
  Future<List<RideRequest>> getIncomingRequestsForRide(String rideId) async {
    final response = await _client
        .from('ride_requests')
        .select('*, profiles:requester_id(display_name, avatar_url, home_city)')
        .eq('ride_id', rideId)
        .order('created_at', ascending: false);

    return (response as List).map((row) => RideRequest.fromMap(row as Map<String, dynamic>)).toList();
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

  /// Fetches ALL incoming requests for any ride owned by this driver
  Future<List<Map<String, dynamic>>> getAllIncomingRequestsForDriver(String driverId) async {
    final response = await _client
        .from('ride_requests')
        .select('*, rides!inner(*, profiles:owner_id(display_name, avatar_url)), profiles:requester_id(display_name, avatar_url, home_city)')
        .eq('rides.owner_id', driverId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetches all active conversation threads for a user (as driver or rider)
  Future<List<Map<String, dynamic>>> getAllConversationsForUser(String userId) async {
    final asRider = await _client
        .from('ride_requests')
        .select('*, rides(*, profiles:owner_id(display_name, avatar_url)), profiles:requester_id(display_name, avatar_url)')
        .eq('requester_id', userId)
        .order('created_at', ascending: false);

    final asDriver = await _client
        .from('ride_requests')
        .select('*, rides!inner(*, profiles:owner_id(display_name, avatar_url)), profiles:requester_id(display_name, avatar_url)')
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
