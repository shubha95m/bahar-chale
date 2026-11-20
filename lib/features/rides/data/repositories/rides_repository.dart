import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../../../core/database/local_database.dart';
import '../../domain/entities/ride.dart';

class RidesRepository {
  final SupabaseClient _client;

  RidesRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  /// Creates a new ride in Supabase and caches locally
  Future<Ride> createRide(Ride ride) async {
    final response = await _client
        .from('rides')
        .insert(ride.toMap())
        .select('*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .single();

    final createdRide = Ride.fromMap(response);

    // Cache to local SQLite if available
    try {
      final db = await LocalDatabase.instance;
      if (db != null) {
        await db.insert(
          'local_cached_rides',
          {
            'id': createdRide.id,
            'owner_id': createdRide.ownerId,
            'ride_category': createdRide.rideCategory,
            'vehicle_type': createdRide.vehicleType,
            'origin_city': createdRide.originCity,
            'origin_area': createdRide.originArea,
            'destination_city': createdRide.destinationCity,
            'destination_area': createdRide.destinationArea,
            'travel_date': createdRide.travelDate.toIso8601String().split('T').first,
            'travel_time': createdRide.travelTime,
            'is_time_flexible': createdRide.isTimeFlexible ? 1 : 0,
            'total_seats': createdRide.totalSeats,
            'available_seats': createdRide.availableSeats,
            'contribution_amount': createdRide.contributionAmount,
            'notes': createdRide.notes,
            'status': createdRide.status,
            'updated_at': createdRide.updatedAt.toIso8601String(),
          },
        );
      }
    } catch (_) {
      // Local cache failure should not block cloud save
    }

    return createdRide;
  }

  /// Searches available rides by normalized city names and travel date with pagination
  Future<List<Ride>> searchRides({
    required String originCity,
    required String destinationCity,
    required DateTime travelDate,
    String? rideCategory,
    String? excludeUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final normalizedOrigin = originCity.trim().toLowerCase();
    final normalizedDest = destinationCity.trim().toLowerCase();
    final dateString = travelDate.toIso8601String().split('T').first;

    var query = _client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .ilike('origin_city', '%$normalizedOrigin%')
        .ilike('destination_city', '%$normalizedDest%')
        .eq('travel_date', dateString)
        .eq('status', 'open')
        .gt('available_seats', 0);

    if (excludeUserId != null && excludeUserId.isNotEmpty) {
      query = query.neq('owner_id', excludeUserId);
    }

    if (rideCategory != null && rideCategory.isNotEmpty) {
      query = query.eq('ride_category', rideCategory);
    }

    final response = await query
        .order('travel_time', ascending: true, nullsFirst: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Fetches all active upcoming open rides across the platform with optional fuzzy search
  Future<List<Ride>> getAllAvailableRides({
    String? queryText,
    String? vehicleType,
    String? excludeUserId,
    int limit = 50,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    var query = _client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .eq('status', 'open')
        .gt('available_seats', 0)
        .gte('travel_date', today);

    if (excludeUserId != null && excludeUserId.isNotEmpty) {
      query = query.neq('owner_id', excludeUserId);
    }

    if (vehicleType != null && vehicleType.isNotEmpty && vehicleType != 'all') {
      query = query.eq('vehicle_type', vehicleType);
    }

    if (queryText != null && queryText.trim().isNotEmpty) {
      final clean = queryText.trim().toLowerCase();
      query = query.or('origin_city.ilike.%$clean%,destination_city.ilike.%$clean%,origin_area.ilike.%$clean%,destination_area.ilike.%$clean%');
    }

    final response = await query.order('travel_date', ascending: true).limit(limit);
    return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Fetches rides published by a specific user
  Future<List<Ride>> getMyRides(String userId) async {
    final response = await _client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .eq('owner_id', userId)
        .order('travel_date', ascending: false);

    return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Fetches detailed ride information by ID
  Future<Ride?> getRideDetails(String rideId) async {
    final response = await _client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .eq('id', rideId)
        .maybeSingle();

    if (response == null) return null;
    return Ride.fromMap(response);
  }

  /// Realtime stream of a specific ride's details (updates dynamically when seats are confirmed)
  Stream<Ride?> streamRideDetails(String rideId) {
    return _client
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .asyncMap((_) async => getRideDetails(rideId));
  }

  /// Cancels an open ride
  Future<void> cancelRide(String rideId) async {
    await _client.from('rides').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', rideId);
  }

  /// Permanently deletes an owned ride.
  /// 1. Dispatches instant notifications to all linked passengers with alternate ride suggestions.
  /// 2. Records cancellation in `trip_cancellations` for backend tracking and abuse prevention.
  /// 3. Safely deletes the ride and cascades child records.
  Future<void> deleteRide(String rideId, {String? reason}) async {
    // 1. Fetch ride details to craft informative notification
    Ride? ride;
    try {
      ride = await getRideDetails(rideId);
    } catch (e) {
      debugPrint('Notice: Error fetching ride details before deletion: $e');
    }

    // 2. Fetch all linked passengers from ride_requests
    List<String> linkedPassengerIds = [];
    try {
      final requests = await _client
          .from('ride_requests')
          .select('requester_id, status')
          .eq('ride_id', rideId);
      linkedPassengerIds = (requests as List)
          .map((r) => r['requester_id']?.toString())
          .whereType<String>()
          .toSet()
          .toList();
    } catch (e) {
      debugPrint('Notice: Error fetching linked passengers: $e');
    }

    // 3. Send cancellation notifications to all linked passengers
    final origin = ride?.originCity ?? 'Origin';
    final dest = ride?.destinationCity ?? 'Destination';
    for (final passengerId in linkedPassengerIds) {
      try {
        await _client.from('notifications').insert({
          'recipient_id': passengerId,
          'notification_type': 'trip_cancelled',
          'title': 'Ride Cancelled / यात्रा रद्द हो गई',
          'body': '$origin → $dest: Ride was cancelled by the driver. Please check alternative rides. (चालक द्वारा यात्रा रद्द कर दी गई है।)',
          'reference_id': rideId,
        });
      } catch (e) {
        debugPrint('Error dispatching cancellation notification: $e');
      }
    }

    // 4. Record cancellation in trip_cancellations and update profile only if other members were linked
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId != null && linkedPassengerIds.isNotEmpty) {
      try {
        await _client.from('trip_cancellations').insert({
          'user_id': currentUserId,
          'entity_type': 'driver_ride',
          'entity_id': rideId,
          'reason': reason ?? 'Driver cancelled ride with linked passengers',
          'affected_users_count': linkedPassengerIds.length,
        });

        // Increment cancellation count on user profile
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

    // 5. Delete the ride
    await _client.from('rides').delete().eq('id', rideId);
  }
}
