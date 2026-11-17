import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../domain/entities/ride_agreement.dart';

class AgreementRepository {
  final SupabaseClient _client;

  AgreementRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  /// Fetches agreement associated with a ride request
  Future<RideAgreement?> getAgreementByRequestId(String requestId) async {
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
}
