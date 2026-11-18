import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/configuration/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/ride_requests_repository.dart';
import '../../domain/entities/ride_request.dart';

final rideRequestsRepositoryProvider = Provider<RideRequestsRepository>((ref) {
  return RideRequestsRepository();
});

/// Live Realtime stream of incoming requests for a specific ride
final incomingRequestsProvider = StreamProvider.family<List<RideRequest>, String>((ref, rideId) async* {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  final controller = StreamController<List<RideRequest>>();

  final initial = await repo.getIncomingRequestsForRide(rideId);
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:ride_incoming:$rideId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'ride_requests',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'ride_id',
          value: rideId,
        ),
        callback: (_) async {
          final fresh = await repo.getIncomingRequestsForRide(rideId);
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 4), (_) async {
    final fresh = await repo.getIncomingRequestsForRide(rideId);
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

/// Live Realtime stream of requests sent by a passenger to rides.
/// Instantly updates when driver accepts or rejects without manual refresh.
final myRequestsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async* {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  final controller = StreamController<List<Map<String, dynamic>>>();

  final initial = await repo.getMyRequestsWithRide(userId);
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:my_sent_requests:$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'ride_requests',
        callback: (_) async {
          final fresh = await repo.getMyRequestsWithRide(userId);
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 4), (_) async {
    final fresh = await repo.getMyRequestsWithRide(userId);
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

/// Live Realtime stream of ALL incoming requests across all rides owned by this driver.
/// Instantly updates when any passenger submits or cancels a request.
final allIncomingRequestsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, driverId) async* {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  final controller = StreamController<List<Map<String, dynamic>>>();

  final initial = await repo.getAllIncomingRequestsForDriver(driverId);
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:driver_all_incoming:$driverId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'ride_requests',
        callback: (_) async {
          final fresh = await repo.getAllIncomingRequestsForDriver(driverId);
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 4), (_) async {
    final fresh = await repo.getAllIncomingRequestsForDriver(driverId);
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

/// Live Realtime stream of conversation threads for this user
final allConversationsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async* {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  final controller = StreamController<List<Map<String, dynamic>>>();

  final initial = await repo.getAllConversationsForUser(userId);
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:conversations:$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'ride_messages',
        callback: (_) async {
          final fresh = await repo.getAllConversationsForUser(userId);
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'ride_requests',
        callback: (_) async {
          final fresh = await repo.getAllConversationsForUser(userId);
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 5), (_) async {
    final fresh = await repo.getAllConversationsForUser(userId);
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

final rideRequestDetailsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, requestId) async {
  final repo = ref.watch(rideRequestsRepositoryProvider);
  return repo.getRequestWithDetails(requestId);
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

  Future<bool> delete(String requestId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteRequest(requestId);
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
