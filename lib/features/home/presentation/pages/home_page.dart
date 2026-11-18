import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/app_bottom_bar.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../../core/widgets/passenger_request_card_widget.dart';
import '../../../../core/widgets/ride_card_widget.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../notifications/presentation/widgets/notifications_sheet.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../requests/presentation/providers/passenger_requests_provider.dart';
import '../providers/home_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _activeFeedIndex = 0; // 0 = Driver Rides, 1 = Passenger Travel Requests

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider);
    final unreadMessagesCount = ref.watch(unreadConversationsCountProvider).value ?? 0;
    final unreadNotificationsCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    final userDisplayName = ProfilePage.formatUserName(user, isHindi: s.isHindi);
    final userAvatarUrl = (user?.userMetadata?['avatar_url'] as String?) ?? (user?.userMetadata?['picture'] as String?);

    final upcomingJourneysAsync = user != null ? ref.watch(homeUpcomingJourneysProvider(user.id)) : null;
    final pendingCountAsync = user != null ? ref.watch(homePendingRequestsCountProvider(user.id)) : null;
    final recentRidesAsync = ref.watch(recentRidesFeedProvider);
    final passengerRequestsAsync = ref.watch(allOpenPassengerRequestsProvider(const BrowsePassengerFilter()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.appTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              s.appTagline,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          const LanguageSwitcherButton(),
          // Notifications Bell Icon with real-time counter
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
          // Chat / Messages Icon with real-time counter
          IconButton(
            tooltip: s.navMessagesText,
            icon: Badge.count(
              count: unreadMessagesCount,
              isLabelVisible: unreadMessagesCount > 0,
              backgroundColor: Colors.red.shade700,
              child: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryGreen),
            ),
            onPressed: () => context.push('/conversations'),
          ),
          IconButton(
            tooltip: s.logoutText,
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textMuted),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(s.logoutText),
                  content: Text(s.logoutConfirmText),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(s.cancelText),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(s.logoutText),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authControllerProvider.notifier).signOut();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 14.0, bottom: 90.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Welcome & Greeting Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen.withOpacity(0.12),
                          const Color(0xFFE2E8F0).withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.push('/profile'),
                          borderRadius: BorderRadius.circular(24),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.primaryGreen,
                            backgroundImage: userAvatarUrl != null ? NetworkImage(userAvatarUrl) : null,
                            child: userAvatarUrl == null
                                ? Text(
                                    userDisplayName.isNotEmpty ? userDisplayName[0].toUpperCase() : 'Y',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.isHindi ? 'नमस्ते, $userDisplayName!' : 'Hello, $userDisplayName!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.isHindi
                                    ? 'आज आप यात्रा प्रस्तुत करना चाहते हैं या शामिल होना?'
                                    : 'Would you like to offer a ride or find one today?',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Quick Search Bar
                  InkWell(
                    onTap: () => context.push('/search-rides'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppTheme.primaryGreen, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.isHindi
                                  ? 'कहाँ जाना चाहते हैं? (उदा. Pune ➔ Mumbai)'
                                  : 'Where do you want to go? (e.g. Pune ➔ Mumbai)',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s.isHindi ? 'खोजें' : 'Search',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Two Core Action Cards (Driver Offer vs Passenger Request) - Single Row Equal Height
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Primary Action 1: Offer a Ride (चालक)
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push('/create-ride'),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryGreen, size: 22),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          s.driverRole,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.offerRideTitle,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textDark),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        s.offerRideSubtitle,
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.25),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Primary Action 2: Post Passenger Need (यात्री)
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push('/create-passenger-request'),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.accentAmber.withOpacity(0.4), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentAmber.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentAmber.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.person_pin_circle_rounded, color: AppTheme.accentAmber, size: 22),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentAmber.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          s.riderRole,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentAmber),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.needRideTitle,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textDark),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        s.needRideSubtitle,
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.25),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Pending Requests Alert Banner (if any)
                  if (pendingCountAsync != null)
                    pendingCountAsync.when(
                      data: (count) {
                        if (count == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: InkWell(
                            onTap: () => context.push('/my-travel'),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.amber.shade400),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.notifications_active_rounded, color: Colors.amber.shade800, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      s.isHindi
                                          ? 'आपके पास $count लंबित सवारी अनुरोध हैं! समीक्षा हेतु टैप करें।'
                                          : 'You have $count pending ride requests! Tap to review.',
                                      style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.amber),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                  // 5. Dual Live Marketplace Feeds (Driver Rides vs Passenger Requests)
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<int>(
                          segments: [
                            ButtonSegment(
                              value: 0,
                              icon: const Icon(Icons.directions_car_rounded, size: 16),
                              label: Text(
                                s.availableDrivesTab,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ButtonSegment(
                              value: 1,
                              icon: const Icon(Icons.people_alt_rounded, size: 16),
                              label: Text(
                                s.passengerRequestsTab,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          selected: {_activeFeedIndex},
                          onSelectionChanged: (set) {
                            setState(() => _activeFeedIndex = set.first);
                          },
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: AppTheme.primaryGreen,
                            selectedForegroundColor: Colors.white,
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.textDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // FEED 0: Driver Offered Rides
                  if (_activeFeedIndex == 0) ...[
                    recentRidesAsync.when(
                      data: (recentRides) {
                        if (recentRides.isEmpty) {
                          return _buildEmptyPlaceholder(
                            icon: Icons.commute_outlined,
                            message: s.isHindi
                                ? 'अन्य यात्रियों द्वारा अभी कोई सवारी उपलब्ध नहीं है। पहली सवारी शेयर करें!'
                                : 'No other rides available right now. Be the first to share one!',
                            actionLabel: s.offerRideTitle,
                            onAction: () => context.push('/create-ride'),
                          );
                        }

                        return Column(
                          children: recentRides.take(5).map((ride) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: RideCardWidget(ride: ride),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator())),
                      error: (err, _) {
                        debugPrint('Recent rides error: $err');
                        return _buildEmptyPlaceholder(
                          icon: Icons.refresh_rounded,
                          message: s.isHindi
                              ? 'सवारियां लोड करने में समस्या। कृपया पुनः प्रयास करें।'
                              : 'Unable to load rides right now. Please retry.',
                          actionLabel: s.isHindi ? 'पुनः प्रयास करें' : 'Retry',
                          onAction: () => ref.invalidate(recentRidesFeedProvider),
                        );
                      },
                    ),
                  ],

                  // FEED 1: Passenger Travel Requests
                  if (_activeFeedIndex == 1) ...[
                    passengerRequestsAsync.when(
                      data: (passengerReqs) {
                        if (passengerReqs.isEmpty) {
                          return _buildEmptyPlaceholder(
                            icon: Icons.person_pin_circle_outlined,
                            message: s.isHindi
                                ? 'अभी अन्य सहयात्रियों ने यात्रा का अनुरोध पोस्ट नहीं किया है। अपनी जरूरत साझा करें!'
                                : 'No other travel requests posted yet. Post your need to get offers!',
                            actionLabel: s.needRideTitle,
                            onAction: () => context.push('/create-passenger-request'),
                          );
                        }

                        return Column(
                          children: passengerReqs.take(5).map((req) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: PassengerRequestCardWidget(request: req),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator())),
                      error: (err, _) {
                        debugPrint('Passenger requests error: $err');
                        return _buildEmptyPlaceholder(
                          icon: Icons.refresh_rounded,
                          message: s.isHindi
                              ? 'यात्रा अनुरोध लोड करने में समस्या। कृपया पुनः प्रयास करें।'
                              : 'Unable to load requests right now. Please retry.',
                          actionLabel: s.isHindi ? 'पुनः प्रयास करें' : 'Retry',
                          onAction: () => ref.invalidate(allOpenPassengerRequestsProvider),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 6. Upcoming Journeys Section (if logged in)
                  if (upcomingJourneysAsync != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.upcomingJourneysText,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                        ),
                        TextButton(
                          onPressed: () => context.push('/my-travel'),
                          child: Text(s.isHindi ? 'मेरी यात्राएं →' : 'My Travel →', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    upcomingJourneysAsync.when(
                      data: (journeys) {
                        if (journeys.isEmpty) {
                          return _buildEmptyPlaceholder(
                            icon: Icons.calendar_today_outlined,
                            message: s.noUpcomingJourneysText,
                          );
                        }
                        return Column(
                          children: journeys.map((ride) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.surfaceLight,
                                  child: Icon(Icons.commute_rounded, color: AppTheme.primaryGreen),
                                ),
                                title: Text(ride.routeDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${DateFormat('dd MMM yyyy').format(ride.travelDate)} • ${ride.travelTime ?? (s.isHindi ? 'लचीला समय' : 'Flexible')}',
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                onTap: () => context.push('/ride/${ride.id}'),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => _buildEmptyPlaceholder(
                        icon: Icons.calendar_today_outlined,
                        message: s.noUpcomingJourneysText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomBar(currentIndex: 0),
    );
  }

  Widget _buildEmptyPlaceholder({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.textMuted, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                child: Text('$actionLabel →', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
