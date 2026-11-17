import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../requests/presentation/providers/requests_provider.dart';
import '../providers/rides_provider.dart';

class MyTravelPage extends ConsumerWidget {
  const MyTravelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.navMyTravel)),
        body: const Center(child: Text('कृपया अपनी यात्राएं देखने के लिए साइन इन करें।')),
      );
    }

    final myRidesAsync = ref.watch(myRidesProvider(user.id));
    final myRequestsAsync = ref.watch(myRequestsProvider(user.id));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.navMyTravel),
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'मेरी प्रस्तुत सवारियां'),
              Tab(text: 'मेरे अनुरोध'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: My Offered Rides
            myRidesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('त्रुटि: $err')),
              data: (rides) {
                if (rides.isEmpty) {
                  return _buildEmptyTab(
                    icon: Icons.directions_car_outlined,
                    title: 'आपने अभी कोई सवारी प्रस्तुत नहीं की है',
                    subtitle: 'जब आप कोई यात्रा साझा करेंगे, वह यहाँ दिखाई देगी।',
                    actionLabel: AppStrings.actionGiveRide,
                    onAction: () => context.push('/create-ride'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rides.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          ride.routeDisplay,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('dd MMM yyyy').format(ride.travelDate)} • ${ride.travelTime ?? 'लचीला समय'}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'स्थिति: ${ride.status.toUpperCase()} • उपलब्ध सीटें: ${ride.availableSeats}',
                              style: TextStyle(
                                color: ride.status == 'open' ? AppTheme.primaryGreen : Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => context.push('/ride/${ride.id}'),
                      ),
                    );
                  },
                );
              },
            ),

            // Tab 2: My Submitted Requests
            myRequestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('त्रुटि: $err')),
              data: (requests) {
                if (requests.isEmpty) {
                  return _buildEmptyTab(
                    icon: Icons.commute_outlined,
                    title: 'कोई सवारी अनुरोध नहीं मिला',
                    subtitle: 'जब आप किसी सवारी के लिए अनुरोध करेंगे, उसकी स्थिति यहाँ दिखाई देगी।',
                    actionLabel: AppStrings.actionWantRide,
                    onAction: () => context.push('/search-rides'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final rideMap = req['rides'] as Map<String, dynamic>?;
                    final origin = rideMap?['origin_city'] ?? '';
                    final dest = rideMap?['destination_city'] ?? '';
                    final status = req['status'] as String? ?? 'pending';

                    Color statusColor;
                    String statusText;
                    switch (status) {
                      case 'accepted':
                        statusColor = Colors.green.shade700;
                        statusText = 'स्वीकृत (Accepted)';
                        break;
                      case 'rejected':
                        statusColor = Colors.red.shade700;
                        statusText = 'अस्वीकृत (Rejected)';
                        break;
                      case 'cancelled':
                        statusColor = Colors.grey.shade600;
                        statusText = 'रद्द (Cancelled)';
                        break;
                      default:
                        statusColor = Colors.orange.shade800;
                        statusText = 'लंबित (Pending)';
                    }

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          '$origin → $dest',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'मांगी गई सीटें: ${req['seats_requested']}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'स्थिति: $statusText',
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          if (rideMap?['id'] != null) {
                            context.push('/ride/${rideMap!['id']}');
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 44)),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
