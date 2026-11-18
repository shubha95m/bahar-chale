import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/entities/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Stream provider for realtime unread conversation badge count
final unreadConversationsCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(0);
  }

  final repo = ref.watch(chatRepositoryProvider);
  final controller = StreamController<int>.broadcast();

  Future<void> update() async {
    try {
      final count = await repo.getUnreadConversationsCount(user.id);
      if (!controller.isClosed) {
        controller.add(count);
      }
    } catch (_) {}
  }

  // 1. Initial fetch
  update();

  // 2. Realtime subscription for incoming messages
  final channel = repo.subscribeToUnreadMessages(
    onChange: () => update(),
  );

  // 3. Periodic safety check every 5 seconds for instant badge sync
  final timer = Timer.periodic(const Duration(seconds: 5), (_) => update());

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final String _requestId;
  final String? _currentUserId;
  RealtimeChannel? _subscription;

  ChatController(this._repository, this._requestId, [this._currentUserId]) : super(const ChatState(isLoading: true)) {
    _init();
  }

  void _init() async {
    try {
      if (_currentUserId != null) {
        await _repository.markMessagesAsRead(
          requestId: _requestId,
          currentUserId: _currentUserId,
        );
      }
      final history = await _repository.getMessages(_requestId);
      state = state.copyWith(messages: history, isLoading: false);

      // Subscribe to Realtime channel
      _subscription = _repository.subscribeToMessages(
        requestId: _requestId,
        onInsert: (payload) {
          final newMsg = ChatMessage.fromMap(payload);
          // If receiving a message while actively inside the chat screen, mark it read
          if (_currentUserId != null && newMsg.senderId != _currentUserId) {
            _repository.markMessagesAsRead(
              requestId: _requestId,
              currentUserId: _currentUserId,
            );
          }
          // Prevent duplicates
          if (!state.messages.any((m) => m.id == newMsg.id)) {
            state = state.copyWith(messages: [...state.messages, newMsg]);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  Future<bool> send({required String senderId, required String body}) async {
    if (body.trim().isEmpty) return false;
    try {
      final sent = await _repository.sendMessage(
        requestId: _requestId,
        senderId: senderId,
        body: body,
      );
      if (!state.messages.any((m) => m.id == sent.id)) {
        state = state.copyWith(messages: [...state.messages, sent]);
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final chatControllerProvider = StateNotifierProvider.autoDispose.family<ChatController, ChatState, String>((ref, requestId) {
  final repo = ref.watch(chatRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return ChatController(repo, requestId, user?.id);
});
