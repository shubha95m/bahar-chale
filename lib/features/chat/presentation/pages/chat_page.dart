import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../requests/presentation/providers/requests_provider.dart';
import '../providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String requestId;

  const ChatPage({super.key, required this.requestId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String currentUserId) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final success = await ref.read(chatControllerProvider(widget.requestId).notifier).send(
      senderId: currentUserId,
      body: text,
    );

    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final chatState = ref.watch(chatControllerProvider(widget.requestId));
    final currentUser = ref.watch(currentUserProvider);
    final detailsAsync = ref.watch(rideRequestDetailsProvider(widget.requestId));

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.isHindi ? 'बातचीत (Chat)' : 'Chat')),
        body: Center(child: Text(s.isHindi ? 'बातचीत देखने के लिए कृपया साइन इन करें।' : 'Please sign in to view chat.')),
      );
    }

    _scrollToBottom();

    String otherUserName = s.isHindi ? 'सहयात्री / चालक' : 'Participant';
    String otherUserRole = '';
    String? otherUserAvatar;
    String fromCity = '';
    String toCity = '';
    String? rideId;
    bool isDriver = false;

    if (detailsAsync.value != null) {
      final data = detailsAsync.value!;
      final ride = data['rides'] as Map<String, dynamic>?;
      final requester = data['profiles'] as Map<String, dynamic>?;
      final owner = ride?['profiles'] as Map<String, dynamic>?;

      fromCity = ride?['origin_city'] ?? '';
      toCity = ride?['destination_city'] ?? '';
      rideId = ride?['id'];

      final isMeOwner = currentUser.id == ride?['owner_id'];
      isDriver = isMeOwner;
      if (isMeOwner) {
        otherUserName = requester?['display_name'] ?? (s.isHindi ? 'सहयात्री' : 'Passenger');
        otherUserRole = s.isHindi ? 'सहयात्री (Passenger)' : 'Passenger';
        otherUserAvatar = requester?['avatar_url'];
      } else {
        otherUserName = owner?['display_name'] ?? (s.isHindi ? 'चालक' : 'Driver');
        otherUserRole = s.isHindi ? 'चालक (Driver)' : 'Driver';
        otherUserAvatar = owner?['avatar_url'];
      }
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (rideId != null) {
              if (isDriver) {
                context.push('/my-travel');
              } else {
                context.push('/ride/$rideId');
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                  backgroundImage: otherUserAvatar != null ? NetworkImage(otherUserAvatar) : null,
                  child: otherUserAvatar == null
                      ? Text(
                          otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 13),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              otherUserName,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (otherUserRole.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: isDriver ? Colors.blue.shade50 : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDriver ? Colors.blue.shade300 : Colors.amber.shade400,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                otherUserRole,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDriver ? Colors.blue.shade800 : Colors.brown.shade800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (fromCity.isNotEmpty && toCity.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.route_rounded, size: 12, color: AppTheme.primaryGreen),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '$fromCity ➔ $toCity',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 8, color: AppTheme.textMuted),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: s.isHindi ? 'यात्रा समन्वय (Travel Agreement)' : 'Travel Agreement',
            icon: const Icon(Icons.assignment_turned_in_outlined, color: AppTheme.primaryGreen, size: 24),
            onPressed: () => context.push('/agreement/${widget.requestId}'),
          ),
          const LanguageSwitcherButton(),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
            // Messages List
            Expanded(
              child: chatState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : chatState.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_outlined, size: 56, color: Color(0xFFCBD5E1)),
                              const SizedBox(height: 12),
                              Text(
                                s.isHindi ? 'अभी कोई संदेश नहीं है।' : 'No messages yet.',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.isHindi ? 'यात्रा समन्वय के लिए पहला संदेश भेजें!' : 'Send a message to coordinate your journey!',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: chatState.messages.length,
                          itemBuilder: (context, index) {
                            final msg = chatState.messages[index];
                            final isMe = msg.senderId == currentUser.id;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? AppTheme.primaryGreen : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft: Radius.circular(isMe ? 14 : 2),
                                    bottomRight: Radius.circular(isMe ? 2 : 14),
                                  ),
                                  border: Border.all(
                                    color: isMe ? AppTheme.primaryGreen : const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe && msg.senderName != null) ...[
                                      Text(
                                        msg.senderName!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isMe ? Colors.white70 : AppTheme.primaryGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                    Text(
                                      msg.messageBody,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isMe ? Colors.white : AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('hh:mm a').format(msg.createdAt.toLocal()),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe ? Colors.white60 : AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: s.isHindi ? 'संदेश लिखें...' : 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                      ),
                      onSubmitted: (_) => _sendMessage(currentUser.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(currentUser.id),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
