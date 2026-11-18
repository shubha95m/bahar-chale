import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/app_bottom_bar.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../notifications/presentation/widgets/notifications_sheet.dart';
import '../../../requests/presentation/providers/requests_provider.dart';
import '../providers/chat_provider.dart';

class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.conversationsTitle)),
        body: Center(child: Text(s.isHindi ? 'कृपया बातचीत देखने के लिए साइन इन करें।' : 'Please sign in to view your conversations.')),
        bottomNavigationBar: const AppBottomBar(currentIndex: 3),
      );
    }

    final convsAsync = ref.watch(allConversationsProvider(user.id));
    final unreadNotificationsCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.conversationsTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              s.conversationsSubtitle,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          const LanguageSwitcherButton(),
          IconButton(
            tooltip: s.notificationsText,
            icon: Badge.count(
              count: unreadNotificationsCount,
              isLabelVisible: unreadNotificationsCount > 0,
              backgroundColor: Colors.red.shade700,
              child: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryGreen),
            ),
            onPressed: () => NotificationsSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: convsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, color: AppTheme.textMuted, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    s.isHindi ? 'बातचीत लोड करने में असमर्थ' : 'Unable to load conversations',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.isHindi ? 'कृपया इंटरनेट जांचें या पुनः प्रयास करें।' : 'Please check your connection and retry.',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(allConversationsProvider(user.id)),
                    child: Text(s.isHindi ? 'पुनः प्रयास करें' : 'Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (convList) {
            if (convList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 42,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'अभी कोई सक्रिय बातचीत नहीं है',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'जब आप किसी यात्रा के लिए अनुरोध करेंगे या कोई आपकी सवारी में शामिल होना चाहेगा, तो यहाँ सीधे संवाद शुरू हो जाएगा।',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/search-rides'),
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('उपलब्ध सवारियां खोजें'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => ref.refresh(allConversationsProvider(user.id)),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: convList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final conv = convList[index];
                  final requestId = conv['id'] as String;
                  final myRole = conv['my_role'] as String? ?? 'rider';
                  final isDriver = myRole == 'driver';

                  // Ride details
                  final ride = conv['rides'] as Map<String, dynamic>?;
                  final origin = ride?['origin_city'] ?? '';
                  final originArea = ride?['origin_area'] as String?;
                  final dest = ride?['destination_city'] ?? '';
                  final destArea = ride?['destination_area'] as String?;
                  final travelDateStr = ride?['travel_date'] as String?;
                  final travelTime = ride?['travel_time'] as String?;
                  final vehicleType = ride?['vehicle_type'] as String? ?? 'car';

                  // Other party profile
                  final riderProfile = conv['profiles'] as Map<String, dynamic>?;
                  final driverProfile = ride?['profiles'] as Map<String, dynamic>?;
                  final otherProfile = isDriver ? riderProfile : driverProfile;

                  final otherName = otherProfile?['display_name'] as String? ?? (isDriver ? 'यात्री' : 'चालक');
                  final status = conv['status'] as String? ?? 'pending';
                  final seatsRequested = conv['seats_requested'] ?? 1;

                  // Status styling
                  Color statusColor;
                  String statusLabel;
                  switch (status) {
                    case 'accepted':
                      statusColor = Colors.green.shade700;
                      statusLabel = 'स्वीकृत (Confirmed)';
                      break;
                    case 'rejected':
                      statusColor = Colors.red.shade700;
                      statusLabel = 'अस्वीकृत (Rejected)';
                      break;
                    case 'cancelled':
                      statusColor = Colors.grey.shade600;
                      statusLabel = 'रद्द (Cancelled)';
                      break;
                    default:
                      statusColor = Colors.orange.shade800;
                      statusLabel = 'अनुरोध लंबित (Pending)';
                  }

                  String formattedDate = '';
                  if (travelDateStr != null && travelDateStr.isNotEmpty) {
                    try {
                      final dt = DateTime.parse(travelDateStr);
                      formattedDate = DateFormat('dd MMM yyyy').format(dt);
                    } catch (_) {
                      formattedDate = travelDateStr;
                    }
                  }

                  final vehicleIcon = vehicleType == 'bike' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded;

                  return Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: status == 'accepted' ? Colors.green.shade200 : const Color(0xFFE2E8F0),
                        width: status == 'accepted' ? 1.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await context.push('/chat/$requestId');
                        ref.invalidate(allConversationsProvider(user.id));
                        ref.invalidate(unreadConversationsCountProvider);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Participant Name + Role Badge + Status
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isDriver
                                      ? AppTheme.accentAmber.withOpacity(0.15)
                                      : AppTheme.primaryGreen.withOpacity(0.15),
                                  child: Text(
                                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDriver ? Colors.orange.shade900 : AppTheme.primaryGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        otherName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: isDriver ? Colors.orange.shade50 : Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isDriver ? '👤 साथी यात्री' : '🚗 यात्रा चालक (Driver)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDriver ? Colors.orange.shade800 : Colors.green.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),

                            // Trip Route & Details
                            Row(
                              children: [
                                Icon(vehicleIcon, size: 16, color: AppTheme.primaryGreen),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '$origin ${originArea != null && originArea.isNotEmpty ? "($originArea)" : ""} ➔ $dest ${destArea != null && destArea.isNotEmpty ? "($destArea)" : ""}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  '$formattedDate • ${travelTime ?? 'लचीला समय'}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                                const Spacer(),
                                Text(
                                  '$seatsRequested ${seatsRequested == 1 ? "सीट" : "सीटें"}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Action Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'चैट खोलने के लिए टैप करें',
                                  style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.chat_bubble_rounded, size: 13, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('बातचीत खोलें', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomBar(currentIndex: 3),
    );
  }
}
