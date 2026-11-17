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
}
