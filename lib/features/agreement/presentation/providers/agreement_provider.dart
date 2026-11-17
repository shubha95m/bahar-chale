import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/agreement_repository.dart';
import '../../domain/entities/ride_agreement.dart';

final agreementRepositoryProvider = Provider<AgreementRepository>((ref) {
  return AgreementRepository();
});

final agreementByRequestProvider = FutureProvider.family<RideAgreement?, String>((ref, requestId) async {
  final repo = ref.watch(agreementRepositoryProvider);
  return repo.getAgreementByRequestId(requestId);
});

class AgreementNotifier extends StateNotifier<AsyncValue<void>> {
  final AgreementRepository _repository;

  AgreementNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> confirm(String agreementId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.confirmAgreement(agreementId);
      if (res['success'] == true) {
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception(res['error'] ?? 'Confirmation failed');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateTerms({
    required String agreementId,
    required String pickupDetails,
    required String dropDetails,
    String? agreedTime,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateDetails(
        agreementId: agreementId,
        pickupDetails: pickupDetails,
        dropDetails: dropDetails,
        agreedTime: agreedTime,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final agreementNotifierProvider = StateNotifierProvider<AgreementNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(agreementRepositoryProvider);
  return AgreementNotifier(repo);
});
