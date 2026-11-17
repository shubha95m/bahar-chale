import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/entities/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
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

  ChatController(this._repository, this._requestId) : super(const ChatState(isLoading: true)) {
    _init();
  }

  void _init() async {
    try {
      final history = await _repository.getMessages(_requestId);
      state = state.copyWith(messages: history, isLoading: false);

      // Subscribe to Realtime channel
      _repository.subscribeToMessages(
        requestId: _requestId,
        onInsert: (payload) {
          final newMsg = ChatMessage.fromMap(payload);
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

final chatControllerProvider = StateNotifierProvider.family<ChatController, ChatState, String>((ref, requestId) {
  final repo = ref.watch(chatRepositoryProvider);
  return ChatController(repo, requestId);
});
