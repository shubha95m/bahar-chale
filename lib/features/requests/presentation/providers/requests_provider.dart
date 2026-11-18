import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ride_requests_repository.dart';
import '../../domain/entities/ride_request.dart';

final rideRequestsRepositoryProvider = Provider<RideRequestsRepository>((ref) {
  return RideRequestsRepository();
});

final incomingRequestsProvider = FutureProvider.family<List<RideRequest>, String>((ref, rideId) async {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  return repo.getIncomingRequestsForRide(rideId);
});

final myRequestsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  return repo.getMyRequestsWithRide(userId);
});

final allIncomingRequestsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, driverId) async {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  return repo.getAllIncomingRequestsForDriver(driverId);
});

final allConversationsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  return repo.getAllConversationsForUser(userId);
});

class RequestActionNotifier extends StateNotifier<AsyncValue<void>> {
  final RideRequestsRepository _repository;

  RequestActionNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> sendRequest({
    required String rideId,
    required String requesterId,
    int seatsRequested = 1,
    String? message,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createRequest(
        rideId: rideId,
        requesterId: requesterId,
        seatsRequested: seatsRequested,
        message: message,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> accept(String requestId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.acceptRequest(requestId);
      if (res['success'] == true) {
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception(res['error'] ?? 'Acceptance failed');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> reject(String requestId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.rejectRequest(requestId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> cancel(String requestId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelRequest(requestId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final requestActionNotifierProvider = StateNotifierProvider<RequestActionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  return RequestActionNotifier(repo);
});
