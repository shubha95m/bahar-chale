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
        .select('*, profiles:owner_id(display_name, avatar_url)')
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
    int limit = 20,
    int offset = 0,
  }) async {
    final normalizedOrigin = originCity.trim().toLowerCase();
    final normalizedDest = destinationCity.trim().toLowerCase();
    final dateString = travelDate.toIso8601String().split('T').first;

    var query = _client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url)')
        .ilike('origin_city', '%$normalizedOrigin%')
        .ilike('destination_city', '%$normalizedDest%')
        .eq('travel_date', dateString)
        .eq('status', 'open')
        .gt('available_seats', 0);

    if (rideCategory != null && rideCategory.isNotEmpty) {
      query = query.eq('ride_category', rideCategory);
    }

    final response = await query
        .order('travel_time', ascending: true, nullsFirst: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Fetches rides published by a specific user
  Future<List<Ride>> getMyRides(String userId) async {
    final response = await _client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url)')
        .eq('owner_id', userId)
        .order('travel_date', ascending: false);

    return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Fetches detailed ride information by ID
  Future<Ride?> getRideDetails(String rideId) async {
    final response = await _client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url)')
        .eq('id', rideId)
        .maybeSingle();

    if (response == null) return null;
    return Ride.fromMap(response);
  }

  /// Cancels an open ride
  Future<void> cancelRide(String rideId) async {
    await _client.from('rides').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', rideId);
  }
}
