import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utilities/map_launcher.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/widgets/govt_document_gate_dialog.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../requests/presentation/providers/requests_provider.dart';
import '../providers/rides_provider.dart';
import '../widgets/cancellation_warning_dialog.dart';

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

  Future<void> _confirmDeleteRide(
    AppStrings s, {
    bool hasLinkedTravelers = false,
    String route = '',
  }) async {
    final bool confirmed;
    if (hasLinkedTravelers) {
      confirmed = await CancellationWarningDialog.show(
        context,
        s: s,
        title: s.isHindi ? 'सवारी रद्द / हटाएं?' : 'Cancel / Delete Ride?',
        tripDescription: route,
        hasLinkedTravelers: true,
        role: 'driver',
        remainingCancellations: 2,
      );
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(s.isHindi ? 'सवारी हटाएं?' : 'Delete Ride?'),
          content: Text(
            s.isHindi
                ? 'क्या आप इस सवारी को हटाना चाहते हैं? कोई सहयात्री अभी जुड़ा नहीं है।'
                : 'Are you sure you want to delete this ride? No co-travelers are linked to it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancelText),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.isHindi ? 'हटाएं' : 'Delete'),
            ),
          ],
        ),
      ) ?? false;
    }

    if (confirmed == true) {
      final success = await ref.read(rideActionNotifierProvider.notifier).deleteRide(widget.rideId);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: success
            ? (hasLinkedTravelers
                ? (s.isHindi ? 'सवारी रद्द कर दी गई एवं यात्रियों को सूचित कर दिया गया।' : 'Ride cancelled and passengers notified.')
                : (s.isHindi ? 'सवारी हटा दी गई।' : 'Ride deleted successfully.'))
            : (s.isHindi ? 'सवारी हटाने में त्रुटि।' : 'Failed to delete ride.'),
        isSuccess: success,
        isError: !success,
      );
      if (success && mounted) {
        final currentUser = ref.read(currentUserProvider);
        if (currentUser != null) {
          ref.invalidate(myRidesProvider(currentUser.id));
        }
        ref.invalidate(recentRidesFeedProvider);
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    }
  }

  Future<void> _showRequestDialog(String currentUserId, int availableSeats, String? vehicleType) async {
    if (availableSeats <= 0) return;

    // Check mandatory government document record gate
    final allowed = await GovtDocumentGateDialog.ensureVerified(context, ref);
    if (!allowed || !mounted) return;

    if (_seatsToRequest > availableSeats) {
      _seatsToRequest = availableSeats;
    }
    final s = ref.read(stringsProvider);
    final vehicleLabel = vehicleType == 'bike'
        ? (s.isHindi ? '🏍️ बाइक (Bike)' : '🏍️ Bike')
        : (vehicleType == 'car'
            ? (s.isHindi ? '🚗 कार (Car)' : '🚗 Car')
            : (s.isHindi ? '🛺 अन्य / साझा (Other)' : '🛺 Other / Shared'));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(s.isHindi ? 'सवारी के लिए अनुरोध भेजें' : 'Send Ride Request'),
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
                      vehicleLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      s.isHindi ? 'उपलब्ध सीटें: $availableSeats' : 'Available seats: $availableSeats',
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
              Text(
                s.isHindi ? 'आपको कितनी सीटें चाहिए?' : 'How many seats do you need?',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
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
                      s.isHindi ? '(अधिकतम उपलब्ध)' : '(Max available)',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: s.isHindi ? 'चालक के लिए संदेश (वैकल्पिक)' : 'Message to driver (Optional)',
                  hintText: s.isHindi ? 'उदा. पिकअप स्थल या सामान का विवरण' : 'e.g. Pickup point or luggage details',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancelText),
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
                AppSnackBar.show(
                  context,
                  message: success
                      ? (s.isHindi ? 'अनुरोध सफलतापूर्वक भेजा गया!' : 'Ride request sent successfully!')
                      : (s.isHindi ? 'अनुरोध भेजने में विफल (शायद आप पहले ही अनुरोध भेज चुके हैं)।' : 'Failed to send request (you may have already requested).'),
                  isSuccess: success,
                  isError: !success,
                );
                ref.invalidate(incomingRequestsProvider(widget.rideId));
              },
              child: Text(s.isHindi ? 'भेजें' : 'Send'),
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
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.isHindi ? 'सवारी विवरण' : 'Ride Details'),
        actions: [
          rideAsync.maybeWhen(
            data: (ride) {
              if (ride != null && currentUser?.id == ride.ownerId) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  tooltip: s.isHindi ? 'सवारी हटाएं' : 'Delete Ride',
                  onPressed: () => _confirmDeleteRide(
                    s,
                    hasLinkedTravelers: ride.availableSeats < ride.totalSeats,
                    route: ride.routeDisplay,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const LanguageSwitcherButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              s.isHindi ? 'सवारी विवरण लोड करने में समस्या। कृपया पुनः प्रयास करें।' : 'Failed to load ride details. Please retry.',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ),
        ),
        data: (ride) {
          if (ride == null) {
            return Center(
              child: Text(s.isHindi ? 'सवारी नहीं मिली।' : 'Ride not found.'),
            );
          }

          final isOwner = currentUser?.id == ride.ownerId;
          final incomingRequestsAsync = isOwner
              ? ref.watch(incomingRequestsProvider(widget.rideId))
              : null;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 90.0),
              child: Align(
                alignment: Alignment.topCenter,
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
                            backgroundImage: (ride.ownerAvatar != null && ride.ownerAvatar!.isNotEmpty)
                                ? NetworkImage(ride.ownerAvatar!)
                                : null,
                            child: (ride.ownerAvatar == null || ride.ownerAvatar!.isEmpty)
                                ? Text(
                                    ride.ownerName?.isNotEmpty == true ? ride.ownerName![0].toUpperCase() : (s.isHindi ? 'य' : 'U'),
                                    style: const TextStyle(fontSize: 20, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        ride.ownerName ?? (s.isHindi ? 'सवारी प्रदाता (Driver)' : 'Ride Provider'),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (ride.isOwnerVerified) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFA5D6A7)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFF2E7D32)),
                                            const SizedBox(width: 3),
                                            Text(
                                              s.isHindi
                                                  ? 'आईडी सत्यापित (${ride.ownerIdType?.toUpperCase() ?? "GOVT"})'
                                                  : 'ID Verified (${ride.ownerIdType?.toUpperCase() ?? "GOVT"})',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ride.localizedVehicleLabel(isHindi: s.isHindi),
                                  style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (ride.contributionAmount != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(s.isHindi ? 'सहयोग राशि' : 'Contribution', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
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
                                s.isHindi ? 'तारीख' : 'Date',
                                DateFormat('dd MMM yyyy').format(ride.travelDate),
                              ),
                              _buildInfoItem(
                                Icons.access_time_rounded,
                                s.isHindi ? 'समय' : 'Time',
                                ride.travelTime ?? (ride.isTimeFlexible ? (s.isHindi ? 'लचीला समय' : 'Flexible') : (s.isHindi ? 'निर्धारित नहीं' : 'Not set')),
                              ),
                              _buildInfoItem(
                                Icons.airline_seat_recline_normal_rounded,
                                s.isHindi ? 'उपलब्ध सीटें' : 'Available Seats',
                                '${ride.availableSeats} / ${ride.totalSeats}',
                              ),
                            ],
                          ),

                          if (ride.notes != null && ride.notes!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(s.isHindi ? 'अतिरिक्त विवरण:' : 'Additional Details:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                            originArea: ride.originArea,
                            destinationArea: ride.destinationArea,
                            originLat: ride.originLatitude,
                            originLon: ride.originLongitude,
                            destinationLat: ride.destinationLatitude,
                            destinationLon: ride.destinationLongitude,
                          );
                        },
                        icon: const Icon(Icons.map_rounded, color: Colors.blueAccent),
                        label: Text(
                          s.isHindi ? 'Google Maps में पूरा मार्ग देखें (मुफ़्त)' : 'View Route on Google Maps (Free)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section for Owner: Incoming Requests
                    if (isOwner) ...[
                      Text(
                        s.isHindi ? 'इस सवारी के लिए अनुरोध' : 'Requests for this Ride',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 12),
                      incomingRequestsAsync!.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text(
                          s.isHindi ? 'अनुरोध लोड करने में समस्या।' : 'Failed to load requests.',
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                        data: (requests) {
                          if (requests.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                s.isHindi ? 'अभी तक कोई अनुरोध प्राप्त नहीं हुआ है।' : 'No requests received yet.',
                                style: const TextStyle(color: AppTheme.textMuted),
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
                                            backgroundImage: (req.requesterAvatar != null && req.requesterAvatar!.isNotEmpty)
                                                ? NetworkImage(req.requesterAvatar!)
                                                : null,
                                            child: (req.requesterAvatar == null || req.requesterAvatar!.isEmpty)
                                                ? Text(
                                                    req.requesterName?.isNotEmpty == true
                                                        ? req.requesterName![0].toUpperCase()
                                                        : (s.isHindi ? 'य' : 'P'),
                                                    style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        req.requesterName ?? (s.isHindi ? 'यात्री (Passenger)' : 'Passenger'),
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (req.isRequesterVerified) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFE8F5E9),
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: const Color(0xFFA5D6A7)),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Icon(Icons.verified_user_rounded, size: 10, color: Color(0xFF2E7D32)),
                                                            const SizedBox(width: 2),
                                                            Text(
                                                              s.isHindi
                                                                  ? 'सत्यापित (${req.requesterIdType?.toUpperCase() ?? "GOVT"})'
                                                                  : 'Verified (${req.requesterIdType?.toUpperCase() ?? "GOVT"})',
                                                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                Text(
                                                  '${req.seatsRequested} ${s.isHindi ? "सीट मांगी" : (req.seatsRequested == 1 ? "seat requested" : "seats requested")} • ${s.isHindi ? "स्थिति" : "Status"}: ${req.status}',
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
                                                  if (!context.mounted) return;
                                                  AppSnackBar.show(
                                                    context,
                                                    message: success
                                                        ? (s.isHindi ? 'अनुरोध स्वीकार कर लिया गया!' : 'Request accepted!')
                                                        : (s.isHindi ? 'स्वीकृति विफल।' : 'Failed to accept.'),
                                                    isSuccess: success,
                                                    isError: !success,
                                                  );
                                                  ref.invalidate(incomingRequestsProvider(widget.rideId));
                                                  ref.invalidate(rideDetailsProvider(widget.rideId));
                                                },
                                                child: Text(s.isHindi ? 'स्वीकार करें' : 'Accept'),
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
                                                child: Text(s.isHindi ? 'अस्वीकार करें' : 'Reject'),
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
                                                label: Text(s.isHindi ? 'यात्रा समन्वय (Agreement)' : 'Agreement', style: const TextStyle(fontSize: 12)),
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
                                                label: Text(s.isHindi ? 'बातचीत (Chat)' : 'Chat', style: const TextStyle(fontSize: 12)),
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
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        label: Text(
                          s.isHindi ? 'यह सवारी हटाएं (Delete Ride)' : 'Delete this Ride',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _confirmDeleteRide(
                          s,
                          hasLinkedTravelers: ride.availableSeats < ride.totalSeats,
                          route: ride.routeDisplay,
                        ),
                      ),
                    ],

                    // Section for Requester: Request Action
                    if (!isOwner && currentUser != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: ride.availableSeats > 0 && ride.status == 'open'
                            ? () => _showRequestDialog(currentUser.id, ride.availableSeats, ride.vehicleType)
                            : null,
                        child: Text(
                          ride.availableSeats > 0
                              ? (s.isHindi ? 'सवारी का अनुरोध भेजें' : 'Send Ride Request')
                              : (s.isHindi ? 'सीटें भर चुकी हैं (Full)' : 'Full (No seats)'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
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
