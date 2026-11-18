import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../domain/entities/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

/// Stream of unread notification count with instant Realtime triggers
final unreadNotificationsCountProvider = StreamProvider<int>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield 0;
    return;
  }

  final repo = ref.watch(notificationsRepositoryProvider);
  final controller = StreamController<int>();

  // Fetch initial unread count
  final initialCount = await repo.getUnreadCount(user.id);
  if (!controller.isClosed) {
    controller.add(initialCount);
  }

  // Subscribe to realtime database changes for this user's notifications
  final channel = repo.subscribeToUserNotifications(
    userId: user.id,
    onChange: () async {
      final updated = await repo.getUnreadCount(user.id);
      if (!controller.isClosed) {
        controller.add(updated);
      }
    },
  );

  // Periodic safety poll every 20 seconds as fallback
  final timer = Timer.periodic(const Duration(seconds: 20), (_) async {
    final count = await repo.getUnreadCount(user.id);
    if (!controller.isClosed) {
      controller.add(count);
    }
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

/// Notifications list provider
final userNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getNotifications(user.id);
});

class NotificationsController extends StateNotifier<AsyncValue<void>> {
  final NotificationsRepository _repo;
  final Ref _ref;

  NotificationsController(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repo.markAsRead(notificationId);
      _ref.invalidate(userNotificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _repo.markAllAsRead(userId);
      _ref.invalidate(userNotificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, AsyncValue<void>>((ref) {
  final repo = ref.watch(notificationsRepositoryProvider);
  return NotificationsController(repo, ref);
});
