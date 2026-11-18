import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../domain/entities/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

/// Live, Realtime Stream of user notifications with instant database triggers and safety sync
final userNotificationsProvider = StreamProvider<List<AppNotification>>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  final repo = ref.watch(notificationsRepositoryProvider);
  final controller = StreamController<List<AppNotification>>();

  // Initial fetch
  final initialList = await repo.getNotifications(user.id);
  if (!controller.isClosed) {
    controller.add(initialList);
  }

  // Subscribe to realtime database changes for this user's notifications
  final channel = repo.subscribeToUserNotifications(
    userId: user.id,
    onChange: () async {
      final updatedList = await repo.getNotifications(user.id);
      if (!controller.isClosed) {
        controller.add(updatedList);
      }
    },
  );

  // Periodic safety poll every 5 seconds so notification count and list NEVER desync
  final timer = Timer.periodic(const Duration(seconds: 5), (_) async {
    final freshList = await repo.getNotifications(user.id);
    if (!controller.isClosed) {
      controller.add(freshList);
    }
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

/// Unread notification count derived directly from userNotificationsProvider.
/// Guarantees count badge and notification sheet list are 100% in sync at all times.
final unreadNotificationsCountProvider = Provider<AsyncValue<int>>((ref) {
  final notifsAsync = ref.watch(userNotificationsProvider);
  return notifsAsync.whenData((list) => list.where((n) => n.isUnread).length);
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
