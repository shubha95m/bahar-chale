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
    final userDisplayName = (user?.userMetadata?['full_name'] as String?) ??
        (user?.userMetadata?['name'] as String?) ??
        user?.email?.split('@').first ??
        (s.isHindi ? 'यात्री' : 'Traveler');
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
          IconButton(
            tooltip: s.navMessagesText,
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryGreen),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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

                // 3. Two Core Action Cards (Driver Offer vs Passenger Request)
                Row(
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
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
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
                              Text(
                                s.actionGiveRideText,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.isHindi ? 'गाड़ी में सीटें साझा करें' : 'Share seats in car or bike',
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                maxLines: 2,
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
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
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
                              Text(
                                s.isHindi ? 'सवारी चाहिए?' : 'Need a Ride?',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.isHindi ? 'जरूरत पोस्ट करें, ड्राइवर जुड़ेंगे' : 'Post itinerary to get offers',
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                                        ? 'आपके पास $count लंबित सवारी अनुरोध हैं! स्वीकार करने हेतु यहाँ टैप करें।'
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
                              s.isHindi ? 'सवारियां (Rides)' : 'Available Rides',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ButtonSegment(
                            value: 1,
                            icon: const Icon(Icons.people_alt_rounded, size: 16),
                            label: Text(
                              s.isHindi ? 'सहयात्री की जरूरतें' : 'Ride Requests',
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
                              ? 'अभी कोई सवारी उपलब्ध नहीं है। पहली सवारी पोस्ट करें!'
                              : 'No rides published yet. Be the first to offer one!',
                          actionLabel: s.actionGiveRideText,
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
                    error: (err, _) => _buildEmptyPlaceholder(
                      icon: Icons.error_outline_rounded,
                      message: 'त्रुटि: $err',
                    ),
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
                              ? 'अभी किसी सहयात्री ने यात्रा की जरूरत पोस्ट नहीं की है। अपनी जरूरत पोस्ट करें!'
                              : 'No passenger travel requests posted yet. Post your need!',
                          actionLabel: s.isHindi ? 'यात्रा अनुरोध पोस्ट करें' : 'Post Ride Request',
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
                    error: (err, _) => _buildEmptyPlaceholder(
                      icon: Icons.error_outline_rounded,
                      message: 'त्रुटि: $err',
                    ),
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
