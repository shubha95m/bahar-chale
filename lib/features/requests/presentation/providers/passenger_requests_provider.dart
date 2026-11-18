import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/configuration/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/repositories/passenger_requests_repository.dart';
import '../../domain/entities/passenger_request.dart';

final passengerRequestsRepositoryProvider = Provider<PassengerRequestsRepository>((ref) {
  return PassengerRequestsRepository();
});

class BrowsePassengerFilter {
  final String? query;
  final String? vehicleType;
  final String? excludeUserId;

  const BrowsePassengerFilter({this.query, this.vehicleType, this.excludeUserId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowsePassengerFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          vehicleType == other.vehicleType &&
          excludeUserId == other.excludeUserId;

  @override
  int get hashCode => (query ?? '').hashCode ^ (vehicleType ?? '').hashCode ^ (excludeUserId ?? '').hashCode;
}

/// Live Realtime stream of open passenger travel requests (Home feed & Browse).
/// Automatically updates when any traveler creates or deletes an itinerary.
final allOpenPassengerRequestsProvider =
    StreamProvider.family<List<PassengerRequest>, BrowsePassengerFilter>((ref, filter) async* {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(passengerRequestsRepositoryProvider);
  final controller = StreamController<List<PassengerRequest>>();

  Future<List<PassengerRequest>> fetch() => repo.getAllOpenRequests(
        queryText: filter.query,
        vehicleType: filter.vehicleType,
        excludeUserId: filter.excludeUserId ?? user?.id,
      );

  final initial = await fetch();
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:all_passenger_requests')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'passenger_requests',
        callback: (_) async {
          final fresh = await fetch();
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 5), (_) async {
    final fresh = await fetch();
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

/// Live Realtime stream of itineraries posted by this user.
final myPassengerRequestsProvider =
    StreamProvider.family<List<PassengerRequest>, String>((ref, userId) async* {
  final repo = ref.watch(passengerRequestsRepositoryProvider);
  final controller = StreamController<List<PassengerRequest>>();

  final initial = await repo.getMyRequests(userId);
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:my_passenger_requests:$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'passenger_requests',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'requester_id',
          value: userId,
        ),
        callback: (_) async {
          final fresh = await repo.getMyRequests(userId);
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 4), (_) async {
    final fresh = await repo.getMyRequests(userId);
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

class PassengerRequestActionNotifier extends StateNotifier<AsyncValue<void>> {
  final PassengerRequestsRepository _repo;

  PassengerRequestActionNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<PassengerRequest?> submit(PassengerRequest request) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repo.createRequest(request);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> cancel(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.cancelRequest(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteRequest(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String?> reachOut({
    required PassengerRequest passengerRequest,
    required String driverId,
    required String vehicleType,
    required String departureTime,
    required int totalSeats,
    required String initialMessage,
  }) async {
    state = const AsyncValue.loading();
    try {
      final rideRequestId = await _repo.reachOutToPassenger(
        passengerRequest: passengerRequest,
        driverId: driverId,
        vehicleType: vehicleType,
        departureTime: departureTime,
        totalSeats: totalSeats,
        initialMessage: initialMessage,
      );
      state = const AsyncValue.data(null);
      return rideRequestId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final passengerRequestActionNotifierProvider =
    StateNotifierProvider<PassengerRequestActionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(passengerRequestsRepositoryProvider);
  return PassengerRequestActionNotifier(repo);
});
