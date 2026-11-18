import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider);
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryGreen, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        s.isHindi ? 'सूचनाएं और अपडेट्स' : 'Notifications & Updates',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  if (user != null)
                    TextButton(
                      onPressed: () {
                        ref.read(notificationsControllerProvider.notifier).markAllAsRead(user.id);
                      },
                      child: Text(
                        s.isHindi ? 'सभी पढ़ें' : 'Mark all read',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Content
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 36,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              s.isHindi ? 'कोई नई सूचना नहीं है' : 'No new notifications',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.isHindi
                                  ? 'सवारी अनुरोध, स्वीकृति और संदेशों के अपडेट्स यहाँ दिखाई देंगे।'
                                  : 'Updates for ride requests, acceptances, and messages will appear here.',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    itemBuilder: (ctx, index) {
                      final notif = notifications[index];
                      final isUnread = notif.isUnread;

                      IconData iconData = Icons.info_outline_rounded;
                      Color iconColor = AppTheme.primaryGreen;

                      if (notif.notificationType.contains('request') || notif.notificationType.contains('offer')) {
                        iconData = Icons.commute_rounded;
                        iconColor = AppTheme.primaryGreen;
                      } else if (notif.notificationType.contains('accept')) {
                        iconData = Icons.check_circle_rounded;
                        iconColor = Colors.green.shade700;
                      } else if (notif.notificationType.contains('agreement')) {
                        iconData = Icons.assignment_turned_in_rounded;
                        iconColor = Colors.indigo.shade600;
                      } else if (notif.notificationType.contains('cancel')) {
                        iconData = Icons.cancel_outlined;
                        iconColor = Colors.red.shade600;
                      }

                      return InkWell(
                        onTap: () {
                          // Mark as read
                          ref.read(notificationsControllerProvider.notifier).markAsRead(notif.id);
                          Navigator.pop(ctx);

                          // Deep link if referenceId exists
                          if (notif.referenceId != null && notif.referenceId!.isNotEmpty) {
                            if (notif.notificationType.contains('agreement')) {
                              context.push('/agreement/${notif.referenceId}');
                            } else if (notif.notificationType.contains('ride_offer') ||
                                notif.notificationType.contains('request') ||
                                notif.notificationType.contains('message')) {
                              context.push('/chat/${notif.referenceId}');
                            } else {
                              context.push('/ride/${notif.referenceId}');
                            }
                          }
                        },
                        child: Container(
                          color: isUnread ? AppTheme.primaryGreen.withOpacity(0.05) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: iconColor.withOpacity(0.12),
                                    child: Icon(iconData, color: iconColor, size: 20),
                                  ),
                                  if (isUnread)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.title,
                                      style: TextStyle(
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 14,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      notif.body,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppTheme.textMuted,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM, hh:mm a').format(notif.createdAt),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text(
                    s.isHindi ? 'सूचनाएं लोड नहीं हो सकीं' : 'Failed to load notifications',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
