import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/configuration/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/agreement_repository.dart';
import '../../domain/entities/ride_agreement.dart';

final agreementRepositoryProvider = Provider<AgreementRepository>((ref) {
  return AgreementRepository();
});

/// Live Realtime stream of the agreement between driver and passenger.
/// Instantly reacts when either party signs/confirms without manual refresh.
final agreementByRequestProvider = StreamProvider.family<RideAgreement?, String>((ref, requestId) async* {
  final repo = ref.watch(agreementRepositoryProvider);
  final controller = StreamController<RideAgreement?>();

  // 1. Initial fetch
  final initial = await repo.getAgreementByRequestId(requestId);
  if (!controller.isClosed) controller.add(initial);

  // 2. Realtime subscription to ride_agreements changes
  final channel = SupabaseConfig.client
      .channel('realtime:agreement:$requestId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'ride_agreements',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'ride_request_id',
          value: requestId,
        ),
        callback: (_) async {
          final fresh = await repo.getAgreementByRequestId(requestId);
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  // 3. Fast safety sync (every 4 seconds)
  final timer = Timer.periodic(const Duration(seconds: 4), (_) async {
    final fresh = await repo.getAgreementByRequestId(requestId);
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
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
