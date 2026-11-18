import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../domain/entities/ride_agreement.dart';

class AgreementRepository {
  final SupabaseClient _client;

  AgreementRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  /// Fetches or atomically creates agreement associated with a ride request
  Future<RideAgreement?> getAgreementByRequestId(String requestId) async {
    try {
      final rpcRes = await _client.rpc(
        'get_or_create_agreement',
        params: {'p_request_id': requestId},
      );

      if (rpcRes != null && rpcRes is Map && rpcRes['success'] == true) {
        final agrMap = Map<String, dynamic>.from(rpcRes['agreement'] as Map);
        final driverMap = rpcRes['driver'] as Map<String, dynamic>?;
        final passengerMap = rpcRes['passenger'] as Map<String, dynamic>?;
        final rideMap = rpcRes['ride'] as Map<String, dynamic>?;
        final reqMap = rpcRes['request'] as Map<String, dynamic>?;

        agrMap['driver_name'] = driverMap?['name'];
        agrMap['driver_id'] = driverMap?['id'];
        agrMap['passenger_name'] = passengerMap?['name'];
        agrMap['passenger_id'] = passengerMap?['id'];
        agrMap['vehicle_type'] = rideMap?['vehicle_type'];
        agrMap['origin_city'] = rideMap?['origin_city'];
        agrMap['destination_city'] = rideMap?['destination_city'];
        agrMap['seats_requested'] = reqMap?['seats_requested'];

        return RideAgreement.fromMap(agrMap);
      }
    } catch (e) {
      // Fallback to direct query
    }

    final response = await _client
        .from('ride_agreements')
        .select()
        .eq('ride_request_id', requestId)
        .maybeSingle();

    if (response == null) return null;
    return RideAgreement.fromMap(response);
  }

  /// Calls atomic Supabase RPC procedure to confirm the arrangement
  Future<Map<String, dynamic>> confirmAgreement(String agreementId) async {
    final response = await _client.rpc(
      'confirm_agreement',
      params: {'p_agreement_id': agreementId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Updates details of an arrangement (pickup/drop/time)
  Future<void> updateDetails({
    required String agreementId,
    required String pickupDetails,
    required String dropDetails,
    String? agreedTime,
  }) async {
    await _client.from('ride_agreements').update({
      'pickup_details': pickupDetails,
      'drop_details': dropDetails,
      'agreed_time': agreedTime,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', agreementId);
  }

  /// Realtime stream of the agreement for this ride request
  Stream<RideAgreement?> streamAgreementByRequestId(String requestId) {
    return _client
        .from('ride_agreements')
        .stream(primaryKey: ['id'])
        .eq('ride_request_id', requestId)
        .asyncMap((_) => getAgreementByRequestId(requestId));
  }
}
