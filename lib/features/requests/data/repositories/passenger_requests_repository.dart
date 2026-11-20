import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../domain/entities/passenger_request.dart';

class PassengerRequestsRepository {
  final SupabaseClient _client;

  PassengerRequestsRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  /// Creates a new passenger travel request / itinerary
  Future<PassengerRequest> createRequest(PassengerRequest request) async {
    final response = await _client
        .from('passenger_requests')
        .insert(request.toMap())
        .select('*, profiles:requester_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .single();

    return PassengerRequest.fromMap(response);
  }

  /// Fetches all active upcoming passenger requests with optional fuzzy search
  Future<List<PassengerRequest>> getAllOpenRequests({
    String? queryText,
    String? vehicleType,
    String? excludeUserId,
    int limit = 50,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    var query = _client
        .from('passenger_requests')
        .select('*, profiles:requester_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .eq('status', 'open')
        .gte('travel_date', today);

    if (excludeUserId != null && excludeUserId.isNotEmpty) {
      query = query.neq('requester_id', excludeUserId);
    }

    if (vehicleType != null && vehicleType.isNotEmpty && vehicleType != 'all') {
      query = query.or('preferred_vehicle.eq.$vehicleType,preferred_vehicle.eq.any');
    }

    if (queryText != null && queryText.trim().isNotEmpty) {
      final clean = queryText.trim().toLowerCase();
      query = query.or(
          'origin_city.ilike.%$clean%,destination_city.ilike.%$clean%,origin_area.ilike.%$clean%,destination_area.ilike.%$clean%');
    }

    final response = await query.order('travel_date', ascending: true).limit(limit);
    return (response as List).map((row) => PassengerRequest.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Fetches passenger requests published by a specific user
  Future<List<PassengerRequest>> getMyRequests(String userId) async {
    final response = await _client
        .from('passenger_requests')
        .select('*, profiles:requester_id(display_name, avatar_url, id_verified, id_type, id_number_masked)')
        .eq('requester_id', userId)
        .order('travel_date', ascending: false);

    return (response as List).map((row) => PassengerRequest.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Cancels an open passenger request
  Future<void> cancelRequest(String requestId) async {
    await _client.from('passenger_requests').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', requestId);
  }

  /// Permanently deletes an owned passenger request.
  /// No other members are linked to an open bulletin post, so no strike or penalty is applied.
  Future<void> deleteRequest(String requestId) async {
    await _client.from('passenger_requests').delete().eq('id', requestId);
  }

  /// Driver reaches out to a passenger request:
  /// Creates an offered ride + links the passenger request as a ride_request + sends initial chat message.
  /// Returns the rideRequestId so the driver can directly open /chat/{rideRequestId}!
  Future<String> reachOutToPassenger({
    required PassengerRequest passengerRequest,
    required String driverId,
    required String vehicleType, // 'car' | 'bike'
    required String departureTime,
    required int totalSeats,
    required String initialMessage,
  }) async {
    // 1. Create a ride owned by the driver for this route
    final rideInsert = await _client.from('rides').insert({
      'owner_id': driverId,
      'ride_category': 'private_vehicle',
      'vehicle_type': vehicleType,
      'origin_city': passengerRequest.originCity,
      'origin_area': passengerRequest.originArea,
      'destination_city': passengerRequest.destinationCity,
      'destination_area': passengerRequest.destinationArea,
      'travel_date': passengerRequest.travelDate.toIso8601String().split('T').first,
      'travel_time': departureTime,
      'is_time_flexible': passengerRequest.isTimeFlexible,
      'total_seats': totalSeats,
      'available_seats': totalSeats,
      'notes': 'Offered for passenger request / सहयात्री के अनुरोध पर प्रस्तुत सवारी',
      'status': 'open',
    }).select('id').single();

    final rideId = rideInsert['id'] as String;

    // 2. Create the ride_request linking the passenger
    final reqInsert = await _client.from('ride_requests').insert({
      'ride_id': rideId,
      'requester_id': passengerRequest.requesterId,
      'seats_requested': passengerRequest.seatsNeeded,
      'status': 'pending',
      'message': initialMessage,
    }).select('id').single();

    final rideRequestId = reqInsert['id'] as String;

    // 3. Insert initial message in chat
    if (initialMessage.trim().isNotEmpty) {
      await _client.from('ride_messages').insert({
        'ride_request_id': rideRequestId,
        'sender_id': driverId,
        'message_body': initialMessage.trim(),
      });
    }

    // 4. Send real-time notification to the passenger
    try {
      await _client.from('notifications').insert({
        'recipient_id': passengerRequest.requesterId,
        'notification_type': 'ride_offer',
        'reference_id': rideRequestId,
        'title': 'New Ride Offer / नया सवारी प्रस्ताव',
        'body': 'A driver offered a ride for your ${passengerRequest.originCity} ➔ ${passengerRequest.destinationCity} request. Tap to view and chat. (एक चालक ने सवारी प्रस्तुत की है।)',
      });
    } catch (_) {}

    return rideRequestId;
  }
}
