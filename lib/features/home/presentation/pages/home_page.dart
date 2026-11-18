import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userDisplayName = (user?.userMetadata?['full_name'] as String?) ??
        (user?.userMetadata?['name'] as String?) ??
        user?.email?.split('@').first ??
        'यात्री';
    final userAvatarUrl = (user?.userMetadata?['avatar_url'] as String?) ?? (user?.userMetadata?['picture'] as String?);

    final upcomingJourneysAsync = user != null ? ref.watch(homeUpcomingJourneysProvider(user.id)) : null;
    final pendingCountAsync = user != null ? ref.watch(homePendingRequestsCountProvider(user.id)) : null;
    final recentRidesAsync = ref.watch(recentRidesFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appNameHindi,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              AppStrings.tagline,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'संदेश व बातचीत',
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryGreen),
            onPressed: () => context.push('/conversations'),
          ),
          IconButton(
            tooltip: AppStrings.logout,
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textMuted),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(AppStrings.logout),
                  content: const Text(AppStrings.logoutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(AppStrings.logout),
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome greeting banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
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
                                  userDisplayName.isNotEmpty ? userDisplayName[0].toUpperCase() : 'य',
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
                              'नमस्ते, $userDisplayName!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'आज आप कहाँ यात्रा करना चाहते हैं?',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Action 1: Want a Ride (मुझे यात्रा करनी है)
                _buildActionCard(
                  context,
                  title: AppStrings.actionWantRide,
                  subtitle: AppStrings.actionWantRideSubtitle,
                  icon: Icons.search_rounded,
                  color: AppTheme.primaryGreen,
                  onTap: () {
                    context.push('/search-rides');
                  },
                ),
                const SizedBox(height: 16),

                // Primary Action 2: Give a Ride (मैं साथ ले जा सकता हूँ)
                _buildActionCard(
                  context,
                  title: AppStrings.actionGiveRide,
                  subtitle: AppStrings.actionGiveRideSubtitle,
                  icon: Icons.add_circle_outline_rounded,
                  color: AppTheme.accentAmber,
                  onTap: () {
                    context.push('/create-ride');
                  },
                ),
                const SizedBox(height: 32),

                // Pending Requests Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.pendingRequests,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (pendingCountAsync != null)
                      pendingCountAsync.when(
                        data: (count) => count > 0
                            ? TextButton(
                                onPressed: () => context.push('/my-travel'),
                                child: Text('$count नए अनुरोध देखें →', style: const TextStyle(fontWeight: FontWeight.bold)),
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (pendingCountAsync != null)
                  pendingCountAsync.when(
                    data: (count) {
                      if (count == 0) {
                        return _buildEmptyPlaceholder(
                          icon: Icons.inbox_outlined,
                          message: AppStrings.noPendingRequests,
                        );
                      }
                      return InkWell(
                        onTap: () => context.push('/my-travel'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notifications_active_rounded, color: Colors.amber.shade800, size: 26),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'आपके पास $count लंबित सवारी अनुरोध हैं। विवरण देखने और स्वीकार करने के लिए यहाँ टैप करें।',
                                  style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.amber),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildEmptyPlaceholder(
                      icon: Icons.inbox_outlined,
                      message: AppStrings.noPendingRequests,
                    ),
                  )
                else
                  _buildEmptyPlaceholder(
                    icon: Icons.inbox_outlined,
                    message: AppStrings.noPendingRequests,
                  ),
                const SizedBox(height: 28),

                // Upcoming Journeys Section
                const Text(
                  AppStrings.upcomingJourneys,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                if (upcomingJourneysAsync != null)
                  upcomingJourneysAsync.when(
                    data: (journeys) {
                      if (journeys.isEmpty) {
                        return _buildEmptyPlaceholder(
                          icon: Icons.calendar_today_outlined,
                          message: AppStrings.noUpcomingJourneys,
                        );
                      }
                      return Column(
                        children: journeys.map((ride) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppTheme.surfaceLight,
                                child: Icon(Icons.commute_rounded, color: AppTheme.primaryGreen),
                              ),
                              title: Text(ride.routeDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${DateFormat('dd MMM yyyy').format(ride.travelDate)} • ${ride.travelTime ?? 'लचीला समय'}',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              onTap: () => context.push('/ride/${ride.id}'),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildEmptyPlaceholder(
                      icon: Icons.calendar_today_outlined,
                      message: AppStrings.noUpcomingJourneys,
                    ),
                  )
                else
                  _buildEmptyPlaceholder(
                    icon: Icons.calendar_today_outlined,
                    message: AppStrings.noUpcomingJourneys,
                  ),
                const SizedBox(height: 28),

                // Recently Published Rides Feed Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.recentRides,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/search-rides'),
                      child: const Text('सभी देखें →', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                recentRidesAsync.when(
                  data: (recentRides) {
                    if (recentRides.isEmpty) {
                      return _buildEmptyPlaceholder(
                        icon: Icons.commute_outlined,
                        message: 'अभी कोई सवारी प्रकाशित नहीं की गई है। पहली सवारी प्रकाशित करें!',
                      );
                    }
                    return Column(
                      children: recentRides.map((ride) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                              child: Text(
                                ride.ownerName?.isNotEmpty == true ? ride.ownerName![0].toUpperCase() : 'य',
                                style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(ride.routeDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${DateFormat('dd MMM').format(ride.travelDate)} • ${ride.availableSeats} सीट उपलब्ध',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                            trailing: ride.contributionAmount != null
                                ? Text(
                                    '₹${ride.contributionAmount!.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentAmber, fontSize: 15),
                                  )
                                : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                            onTap: () => context.push('/ride/${ride.id}'),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => _buildEmptyPlaceholder(
                    icon: Icons.commute_outlined,
                    message: 'सवारियां लोड नहीं हो सकीं।',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 0) {
            setState(() => _currentIndex = 0);
          } else if (index == 1) {
            context.push('/search-rides');
          } else if (index == 2) {
            context.push('/my-travel');
          } else if (index == 3) {
            context.push('/conversations');
          } else if (index == 4) {
            context.push('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'सवारी खोजें',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.commute_rounded),
            label: AppStrings.navMyTravel,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'संदेश',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
