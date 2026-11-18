import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utilities/map_launcher.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../requests/presentation/providers/requests_provider.dart';
import '../providers/rides_provider.dart';

class MyTravelPage extends ConsumerWidget {
  const MyTravelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.navMyTravelText)),
        body: Center(child: Text(s.isHindi ? 'कृपया अपनी यात्राएं देखने के लिए साइन इन करें।' : 'Please sign in to view your journeys.')),
      );
    }

    final incomingAsync = ref.watch(allIncomingRequestsProvider(user.id));
    final myRidesAsync = ref.watch(myRidesProvider(user.id));
    final myRequestsAsync = ref.watch(myRequestsProvider(user.id));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            s.navMyTravelText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            const LanguageSwitcherButton(),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              tooltip: s.navMessagesText,
              onPressed: () => context.push('/conversations'),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            isScrollable: false,
            tabs: [
              Tab(
                icon: const Icon(Icons.mark_email_unread_outlined, size: 20),
                text: s.tabIncomingText,
              ),
              Tab(
                icon: const Icon(Icons.drive_eta_outlined, size: 20),
                text: s.tabMyDrivesText,
              ),
              Tab(
                icon: const Icon(Icons.outbox_rounded, size: 20),
                text: s.tabMyRequestsText,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Incoming requests for my rides
            _buildIncomingTab(context, ref, user.id, incomingAsync),

            // TAB 2: Rides posted by me
            _buildMyDrivesTab(context, ref, user.id, myRidesAsync),

            // TAB 3: Requests I sent to other drivers
            _buildMySentRequestsTab(context, ref, user.id, myRequestsAsync),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: Incoming requests from co-travelers
  // -------------------------------------------------------------
  Widget _buildIncomingTab(
    BuildContext context,
    WidgetRef ref,
    String userId,
    AsyncValue<List<Map<String, dynamic>>> incomingAsync,
  ) {
    return incomingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text('अनुरोध लोड करने में त्रुटि: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allIncomingRequestsProvider(userId)),
                child: const Text('पुनः प्रयास करें'),
              ),
            ],
          ),
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyTab(
            icon: Icons.inbox_outlined,
            title: 'कोई नया अनुरोध नहीं मिला',
            subtitle: 'जब कोई यात्री आपकी पोस्ट की गई राइड में जुड़ने का अनुरोध करेगा, वह सीधे यहाँ दिखाई देगा।',
            actionLabel: 'सवारी प्रस्तुत करें (Offer Ride)',
            onAction: () => context.push('/create-ride'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(allIncomingRequestsProvider(userId)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final req = requests[index];
              final rideMap = req['rides'] as Map<String, dynamic>? ?? {};
              final requesterMap = req['profiles'] as Map<String, dynamic>? ?? {};

              final origin = rideMap['origin_city'] ?? '';
              final dest = rideMap['destination_city'] ?? '';
              final travelDateRaw = rideMap['travel_date'];
              final travelTime = rideMap['travel_time'] ?? 'समय लचीला';
              DateTime? parsedDate;
              if (travelDateRaw != null) {
                try {
                  parsedDate = DateTime.parse(travelDateRaw.toString());
                } catch (_) {}
              }

              final requesterName = requesterMap['display_name'] ?? 'सहयात्री';
              final status = (req['status'] as String? ?? 'pending').toLowerCase();
              final seatsRequested = req['seats_requested'] ?? 1;
              final userMessage = req['message'] as String?;
              final reqId = req['id'].toString();

              Color statusColor;
              String statusLabel;
              switch (status) {
                case 'accepted':
                  statusColor = Colors.green.shade700;
                  statusLabel = 'स्वीकृत (Accepted)';
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
                  statusLabel = 'नया अनुरोध (Pending)';
              }

              return Card(
                elevation: status == 'pending' ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: status == 'pending' ? AppTheme.primaryGreen.withOpacity(0.5) : const Color(0xFFE2E8F0),
                    width: status == 'pending' ? 1.5 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Requester Name & Status Chip
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                            child: Text(
                              requesterName.isNotEmpty ? requesterName[0].toUpperCase() : 'Y',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  requesterName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  '$seatsRequested सीट का अनुरोध',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Trip Route & Date
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.route_rounded, size: 16, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$origin ➔ $dest',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.event_outlined, size: 15, color: AppTheme.textMuted),
                                const SizedBox(width: 8),
                                Text(
                                  '${parsedDate != null ? DateFormat('dd MMM yyyy').format(parsedDate) : ''} • $travelTime',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (userMessage != null && userMessage.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'यात्री का संदेश: "$userMessage"',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textDark),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Action buttons
                      if (status == 'pending') ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: const Text('स्वीकार करें', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  final success = await ref.read(requestActionNotifierProvider.notifier).accept(reqId);
                                  if (context.mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('अनुरोध स्वीकार कर लिया गया है। सीटें अपडेट हो गई हैं।')),
                                      );
                                      ref.invalidate(allIncomingRequestsProvider(userId));
                                      ref.invalidate(myRidesProvider(userId));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('अनुरोध स्वीकार करने में त्रुटि। संभवतः सीटें समाप्त हो गई हैं।')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(color: Colors.red.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.cancel_outlined, size: 16),
                                label: const Text('मना करें', style: TextStyle(fontSize: 12)),
                                onPressed: () async {
                                  await ref.read(requestActionNotifierProvider.notifier).reject(reqId);
                                  if (context.mounted) {
                                    ref.invalidate(allIncomingRequestsProvider(userId));
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'बातचीत करें',
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryGreen),
                              onPressed: () => context.push('/chat/$reqId'),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryGreen,
                                  side: const BorderSide(color: AppTheme.primaryGreen),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                label: const Text('बातचीत (Chat)', style: TextStyle(fontSize: 12)),
                                onPressed: () => context.push('/chat/$reqId'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (status == 'accepted') ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.handshake_outlined, size: 16),
                                  label: const Text('सहमति पत्र', style: TextStyle(fontSize: 12)),
                                  onPressed: () => context.push('/agreement/$reqId'),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            IconButton(
                              tooltip: 'Google Maps में मार्ग देखें (मुफ़्त)',
                              icon: const Icon(Icons.map_outlined, color: Colors.blueAccent),
                              onPressed: () => MapLauncher.openDirections(origin: origin, destination: dest),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 2: My offered rides (Driver)
  // -------------------------------------------------------------
  Widget _buildMyDrivesTab(
    BuildContext context,
    WidgetRef ref,
    String userId,
    AsyncValue<dynamic> myRidesAsync,
  ) {
    return myRidesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('त्रुटि: $err')),
      data: (rides) {
        if (rides.isEmpty) {
          return _buildEmptyTab(
            icon: Icons.directions_car_outlined,
            title: 'आपने अभी कोई सवारी प्रस्तुत नहीं की है',
            subtitle: 'जब आप कोई यात्रा साझा करेंगे, वह यहाँ दिखाई देगी और अन्य यात्री जुड़ सकेंगे।',
            actionLabel: AppStrings.actionGiveRide,
            onAction: () => context.push('/create-ride'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(myRidesProvider(userId)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ride = rides[index];
              final bookedSeats = ride.totalSeats - ride.availableSeats;
              final isFullyBooked = ride.availableSeats == 0;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ride.routeDisplay,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isFullyBooked
                                  ? Colors.red.withOpacity(0.1)
                                  : AppTheme.primaryGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isFullyBooked ? 'फुल (Full)' : 'सक्रिय (Open)',
                              style: TextStyle(
                                color: isFullyBooked ? Colors.red.shade700 : AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 16, color: AppTheme.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(ride.travelDate)} • ${ride.travelTime ?? 'लचीला समय'}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Vehicle and Seat Status Indicator
                      Row(
                        children: [
                          Icon(
                            ride.vehicleType == 'bike' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                            size: 16,
                            color: AppTheme.textDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${ride.vehicleLabel} • उपलब्ध: ${ride.availableSeats} / ${ride.totalSeats} सीटें ($bookedSeats बुक)',
                            style: TextStyle(
                              color: ride.availableSeats > 0 ? AppTheme.primaryGreen : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.map_outlined, size: 16, color: Colors.blueAccent),
                              label: const Text('Google Maps', style: TextStyle(fontSize: 12)),
                              onPressed: () => MapLauncher.openDirections(
                                origin: ride.originCity,
                                destination: ride.destinationCity,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.group_outlined, size: 16),
                              label: const Text('यात्री व विवरण', style: TextStyle(fontSize: 12)),
                              onPressed: () => context.push('/ride/${ride.id}'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 3: Requests submitted by me (Rider)
  // -------------------------------------------------------------
  Widget _buildMySentRequestsTab(
    BuildContext context,
    WidgetRef ref,
    String userId,
    AsyncValue<List<Map<String, dynamic>>> myRequestsAsync,
  ) {
    return myRequestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('त्रुटि: $err')),
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyTab(
            icon: Icons.commute_outlined,
            title: 'कोई सवारी अनुरोध नहीं मिला',
            subtitle: 'जब आप किसी सवारी के लिए अनुरोध करेंगे, उसकी स्थिति और ड्राइवर की प्रतिक्रिया यहाँ दिखाई देगी।',
            actionLabel: AppStrings.actionWantRide,
            onAction: () => context.push('/search-rides'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(myRequestsProvider(userId)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final req = requests[index];
              final rideMap = req['rides'] as Map<String, dynamic>?;
              final origin = rideMap?['origin_city'] ?? '';
              final dest = rideMap?['destination_city'] ?? '';
              final status = (req['status'] as String? ?? 'pending').toLowerCase();
              final isAccepted = status == 'accepted';
              final reqId = req['id'].toString();

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$origin → $dest',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'मांगी गई सीटें: ${req['seats_requested']}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          if (isAccepted) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(38),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.handshake_outlined, size: 16),
                                label: const Text('सहमति पत्र', style: TextStyle(fontSize: 12)),
                                onPressed: () => context.push('/agreement/$reqId'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(38),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                label: const Text('बातचीत', style: TextStyle(fontSize: 12)),
                                onPressed: () => context.push('/chat/$reqId'),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(38),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                label: const Text('बातचीत (Chat)', style: TextStyle(fontSize: 12)),
                                onPressed: () => context.push('/chat/$reqId'),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          IconButton(
                            tooltip: 'Google Maps में मार्ग देखें (मुफ़्त)',
                            icon: const Icon(Icons.map_outlined, color: Colors.blueAccent),
                            onPressed: () => MapLauncher.openDirections(origin: origin, destination: dest),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
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
