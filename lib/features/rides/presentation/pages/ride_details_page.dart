import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utilities/map_launcher.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../requests/presentation/providers/requests_provider.dart';
import '../providers/rides_provider.dart';

class RideDetailsPage extends ConsumerStatefulWidget {
  final String rideId;

  const RideDetailsPage({super.key, required this.rideId});

  @override
  ConsumerState<RideDetailsPage> createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends ConsumerState<RideDetailsPage> {
  int _seatsToRequest = 1;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showRequestDialog(BuildContext dialogContext, String currentUserId, int availableSeats, String? vehicleType) {
    if (availableSeats <= 0) return;
    if (_seatsToRequest > availableSeats) {
      _seatsToRequest = availableSeats;
    }

    showDialog(
      context: dialogContext,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('सवारी के लिए अनुरोध भेजें'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle and availability badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vehicleType == 'bike' ? '🏍️ बाइक' : (vehicleType == 'car' ? '🚗 कार' : '🛺 साझा'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'उपलब्ध सीटें: $availableSeats',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: availableSeats == 1 ? Colors.orange.shade800 : AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('आपको कितनी सीटें चाहिए?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryGreen, size: 28),
                    onPressed: _seatsToRequest > 1
                        ? () => setDialogState(() => _seatsToRequest--)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      '$_seatsToRequest',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen, size: 28),
                    onPressed: _seatsToRequest < availableSeats
                        ? () => setDialogState(() => _seatsToRequest++)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  if (_seatsToRequest >= availableSeats)
                    Text(
                      '(अधिकतम उपलब्ध)',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'चालक के लिए संदेश (वैकल्पिक)',
                  hintText: 'उदा. पिकअप स्थल या सामान का विवरण',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await ref.read(requestActionNotifierProvider.notifier).sendRequest(
                  rideId: widget.rideId,
                  requesterId: currentUserId,
                  seatsRequested: _seatsToRequest,
                  message: _messageController.text.trim().isNotEmpty ? _messageController.text.trim() : null,
                );

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'अनुरोध सफलतापूर्वक भेजा गया!'
                          : 'अनुरोध भेजने में विफल (शायद आप पहले ही अनुरोध भेज चुके हैं)।',
                    ),
                    backgroundColor: success ? AppTheme.primaryGreen : Colors.red,
                  ),
                );
                ref.invalidate(incomingRequestsProvider(widget.rideId));
              },
              child: const Text('भेजें'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideDetailsProvider(widget.rideId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('सवारी विवरण'),
      ),
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('त्रुटि: ${err.toString()}')),
        data: (ride) {
          if (ride == null) {
            return const Center(child: Text('सवारी नहीं मिली।'));
          }

          final isOwner = currentUser?.id == ride.ownerId;
          final incomingRequestsAsync = isOwner
              ? ref.watch(incomingRequestsProvider(widget.rideId))
              : null;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Provider Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                            child: Text(
                              ride.ownerName?.isNotEmpty == true ? ride.ownerName![0].toUpperCase() : 'य',
                              style: const TextStyle(fontSize: 20, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ride.ownerName ?? 'सवारी प्रदाता',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                                Text(
                                  ride.vehicleLabel,
                                  style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (ride.contributionAmount != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('सहयोग राशि', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                Text(
                                  '₹${ride.contributionAmount!.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.accentAmber),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Route & Schedule Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Origin
                          Row(
                            children: [
                              const Icon(Icons.radio_button_checked, color: AppTheme.primaryGreen, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ride.originArea != null ? '${ride.originCity} (${ride.originArea})' : ride.originCity,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 9.0),
                            child: Container(
                              height: 24,
                              width: 2,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                          // Destination
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.accentAmber, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ride.destinationArea != null ? '${ride.destinationCity} (${ride.destinationArea})' : ride.destinationCity,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28),

                          // Date, Time, Seats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoItem(
                                Icons.calendar_today_rounded,
                                'तारीख',
                                DateFormat('dd MMM yyyy').format(ride.travelDate),
                              ),
                              _buildInfoItem(
                                Icons.access_time_rounded,
                                'समय',
                                ride.travelTime ?? (ride.isTimeFlexible ? 'लचीला समय' : 'निर्धारित नहीं'),
                              ),
                              _buildInfoItem(
                                Icons.airline_seat_recline_normal_rounded,
                                'उपलब्ध सीटें',
                                '${ride.availableSeats} / ${ride.totalSeats}',
                              ),
                            ],
                          ),

                          if (ride.notes != null && ride.notes!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text('अतिरिक्त विवरण:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(ride.notes!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Google Maps Navigation (Zero Cost Deep Link)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          MapLauncher.openDirections(
                            origin: ride.originCity,
                            destination: ride.destinationCity,
                          );
                        },
                        icon: const Icon(Icons.map_rounded, color: Colors.blueAccent),
                        label: const Text('Google Maps में पूरा मार्ग देखें (मुफ़्त)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section for Owner: Incoming Requests
                    if (isOwner) ...[
                      const Text(
                        'इस सवारी के लिए अनुरोध',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 12),
                      incomingRequestsAsync!.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('अनुरोध लोड करने में त्रुटि: $err'),
                        data: (requests) {
                          if (requests.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Text(
                                'अभी तक कोई अनुरोध प्राप्त नहीं हुआ है।',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            );
                          }

                          return Column(
                            children: requests.map((req) {
                              final isPending = req.status == 'pending';
                              final isAccepted = req.status == 'accepted';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                                            child: Text(
                                              req.requesterName?.isNotEmpty == true
                                                  ? req.requesterName![0].toUpperCase()
                                                  : 'य',
                                              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  req.requesterName ?? 'यात्री',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  '${req.seatsRequested} सीट मांगी • स्थिति: ${req.status}',
                                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (req.message != null) ...[
                                        const SizedBox(height: 8),
                                        Text('"${req.message!}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                                      ],
                                      if (isPending) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.primaryGreen,
                                                  minimumSize: const Size.fromHeight(38),
                                                ),
                                                onPressed: () async {
                                                  final success = await ref.read(requestActionNotifierProvider.notifier).accept(req.id);
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(success ? 'अनुरोध स्वीकार कर लिया गया!' : 'स्वीकृति विफल।'),
                                                      backgroundColor: success ? AppTheme.primaryGreen : Colors.red,
                                                    ),
                                                  );
                                                  ref.invalidate(incomingRequestsProvider(widget.rideId));
                                                  ref.invalidate(rideDetailsProvider(widget.rideId));
                                                },
                                                child: const Text('स्वीकार करें'),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                  side: const BorderSide(color: Colors.red),
                                                  minimumSize: const Size.fromHeight(38),
                                                ),
                                                onPressed: () async {
                                                  await ref.read(requestActionNotifierProvider.notifier).reject(req.id);
                                                  ref.invalidate(incomingRequestsProvider(widget.rideId));
                                                },
                                                child: const Text('अस्वीकार करें'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (isAccepted) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.primaryGreen,
                                                  minimumSize: const Size.fromHeight(34),
                                                ),
                                                icon: const Icon(Icons.handshake_outlined, size: 16),
                                                label: const Text('यात्रा समन्वय', style: TextStyle(fontSize: 12)),
                                                onPressed: () => context.push('/agreement/${req.id}'),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  minimumSize: const Size.fromHeight(34),
                                                ),
                                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                                label: const Text('बातचीत (Chat)', style: TextStyle(fontSize: 12)),
                                                onPressed: () => context.push('/chat/${req.id}'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],

                    // Section for Requester: Request Action
                    if (!isOwner && currentUser != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: ride.availableSeats > 0 && ride.status == 'open'
                            ? () => _showRequestDialog(context, currentUser.id, ride.availableSeats, ride.vehicleType)
                            : null,
                        child: Text(
                          ride.availableSeats > 0 ? AppStrings.sendRequest : 'सीटें भर चुकी हैं (Full)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }
}
