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
import '../providers/agreement_provider.dart';

class AgreementPage extends ConsumerWidget {
  final String requestId;

  const AgreementPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final agreementAsync = ref.watch(agreementByRequestProvider(requestId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Subtle clean desk background
      appBar: AppBar(
        title: Text(s.agreementTitle),
        actions: [
          IconButton(
            tooltip: s.chatText,
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryGreen),
            onPressed: () => context.push('/chat/$requestId'),
          ),
          const LanguageSwitcherButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: agreementAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryGreen),
              SizedBox(height: 16),
              Text(
                'यात्रा समन्वय पत्र लोड हो रहा है...',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.amber),
                const SizedBox(height: 12),
                Text(
                  s.isHindi ? 'समन्वय पत्र लोड करने में समस्या।' : 'Unable to load agreement right now.',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(agreementByRequestProvider(requestId)),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(s.isHindi ? 'पुनः प्रयास करें' : 'Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (agreement) {
          if (agreement == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.assignment_outlined, size: 54, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 12),
                  Text(
                    s.agreementEmptyState,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final isConfirmed = agreement.status == 'confirmed' || agreement.isFullyConfirmed;
          final isDriver = currentUser?.id != null && currentUser!.id == agreement.driverId;
          final isPassenger = currentUser?.id != null && currentUser!.id == agreement.passengerId;
          final hasMyConfirmed = (isDriver && agreement.ownerConfirmed) || (isPassenger && agreement.requesterConfirmed);

          return SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      // ========================================================
                      // 1080p / 4K Ultra-Crisp Digital Certificate (समन्वय पत्र)
                      // ========================================================
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF0F766E), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(7),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCFDFD),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isConfirmed ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top Certificate Header with Seal & Badge
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left: App Brand & Certificate Title
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryGreen.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.verified_rounded,
                                                color: AppTheme.primaryGreen,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  s.isHindi ? 'बाहर चलें (Bahar Chale)' : 'Bahar Chale',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: AppTheme.primaryGreen,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                Text(
                                                  s.certificateSubtitle,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppTheme.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          s.certificateTitle,
                                          style: const TextStyle(
                                            fontFamily: 'serif',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 21,
                                            letterSpacing: 0.3,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${s.certificateRef}: BC-AGR-${agreement.id.replaceAll("-", "").substring(0, 8).toUpperCase()}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Right: High-Res Circular Verification Seal
                                  Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isConfirmed ? Colors.green.shade50 : Colors.amber.shade50,
                                      border: Border.all(
                                        color: isConfirmed ? Colors.green.shade600 : Colors.amber.shade600,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isConfirmed ? Colors.green : Colors.amber).withOpacity(0.18),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isConfirmed ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                                            color: isConfirmed ? Colors.green.shade800 : Colors.amber.shade800,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isConfirmed
                                                ? (s.isHindi ? 'सत्यापित' : 'VERIFIED')
                                                : (s.isHindi ? 'प्रतीक्षित' : 'PENDING'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 9.5,
                                              letterSpacing: 0.6,
                                              color: isConfirmed ? Colors.green.shade900 : Colors.amber.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 20),

                              // Two Contract Parties (Driver & Passenger)
                              LayoutBuilder(
                                builder: (ctx, constraints) {
                                  final isWide = constraints.maxWidth > 500;
                                  final driverWidget = _buildPartyCard(
                                    roleLabel: s.driverParty,
                                    partyName: agreement.driverName ?? (s.isHindi ? 'सवारी प्रदाता (चालक)' : 'Ride Provider'),
                                    icon: agreement.vehicleType == 'bike' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                                    subInfo: agreement.vehicleType == 'bike' ? s.bikeText : s.carText,
                                    isConfirmed: agreement.ownerConfirmed,
                                    confirmedStamp: s.driverConfirmedStamp,
                                    pendingStamp: s.pendingConfirmationStamp,
                                    isMe: isDriver,
                                    s: s,
                                  );

                                  final passengerWidget = _buildPartyCard(
                                    roleLabel: s.passengerParty,
                                    partyName: agreement.passengerName ?? (s.isHindi ? 'सहयात्री' : 'Co-Traveler'),
                                    icon: Icons.person_rounded,
                                    subInfo: '${agreement.seatsRequested ?? 1} ${s.isHindi ? "सीट" : "Seat(s)"}',
                                    isConfirmed: agreement.requesterConfirmed,
                                    confirmedStamp: s.passengerConfirmedStamp,
                                    pendingStamp: s.pendingConfirmationStamp,
                                    isMe: isPassenger,
                                    s: s,
                                  );

                                  if (isWide) {
                                    return Row(
                                      children: [
                                        Expanded(child: driverWidget),
                                        const SizedBox(width: 14),
                                        Expanded(child: passengerWidget),
                                      ],
                                    );
                                  }

                                  return Column(
                                    children: [
                                      driverWidget,
                                      const SizedBox(height: 12),
                                      passengerWidget,
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 22),

                              // Journey Details Table Box
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFEDF2F7)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.route_rounded, color: AppTheme.primaryGreen, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          s.itinerarySection,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20, thickness: 0.8),
                                    _buildDetailRow(
                                      Icons.place_outlined,
                                      s.pickupPoint,
                                      agreement.pickupDetails.isNotEmpty ? agreement.pickupDetails : (agreement.originCity ?? 'N/A'),
                                      iconColor: AppTheme.primaryGreen,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      Icons.flag_outlined,
                                      s.dropPoint,
                                      agreement.dropDetails.isNotEmpty ? agreement.dropDetails : (agreement.destinationCity ?? 'N/A'),
                                      iconColor: AppTheme.accentAmber,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      Icons.calendar_month_rounded,
                                      s.travelDateTime,
                                      '${DateFormat('dd MMMM yyyy').format(agreement.agreedDate)} • ${agreement.agreedTime ?? (s.isHindi ? 'लचीला समय' : 'Flexible')}',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      Icons.currency_rupee_rounded,
                                      s.contributionLabel,
                                      agreement.agreedContribution != null
                                          ? '₹${agreement.agreedContribution!.toStringAsFixed(0)}'
                                          : s.freeCommunityRide,
                                      highlightValue: true,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Mutual Confirmation Bottom Banner
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isConfirmed ? Colors.green.shade50 : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isConfirmed ? Colors.green.shade300 : Colors.amber.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isConfirmed ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                      color: isConfirmed ? Colors.green.shade800 : Colors.amber.shade900,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        isConfirmed
                                            ? s.bothConfirmedBanner
                                            : (s.isHindi
                                                ? 'सुरक्षित व सुगम यात्रा के लिए चालक व यात्री दोनों पक्षों की आपसी पुष्टि आवश्यक है।'
                                                : 'Mutual confirmation from both driver and passenger ensures a safe, coordinated journey.'),
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: isConfirmed ? FontWeight.bold : FontWeight.w500,
                                          color: isConfirmed ? Colors.green.shade900 : Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ========================================================
                      // Action Buttons (Confirm, Chat, Maps)
                      // ========================================================
                      if (!isConfirmed && !hasMyConfirmed) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                          onPressed: () async {
                            final success = await ref.read(agreementNotifierProvider.notifier).confirm(agreement.id);
                            if (context.mounted) {
                              AppSnackBar.show(
                                context,
                                message: success
                                    ? (s.isHindi ? 'सहमति पत्र की पुष्टि सफलतापूर्वक दर्ज हुई!' : 'Agreement confirmed successfully!')
                                    : (s.isHindi ? 'पुष्टि विफल। कृपया पुनः प्रयास करें।' : 'Confirmation failed. Please retry.'),
                                isSuccess: success,
                                isError: !success,
                              );
                              ref.invalidate(agreementByRequestProvider(requestId));
                            }
                          },
                          label: Text(
                            s.confirmAgreementButton,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ] else if (!isConfirmed && hasMyConfirmed) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                s.isHindi
                                    ? 'आपने पुष्टि कर दी है! दूसरे पक्ष की पुष्टि की प्रतीक्षा है।'
                                    : 'You confirmed! Waiting for co-traveler confirmation.',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Secondary Navigation Buttons (Chat & Maps)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => context.push('/chat/$requestId'),
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                              label: Text(
                                s.chatWithPartnerButton,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                foregroundColor: Colors.blue.shade700,
                                side: BorderSide(color: Colors.blue.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                MapLauncher.openDirections(
                                  origin: agreement.pickupDetails.isNotEmpty ? agreement.pickupDetails : (agreement.originCity ?? ''),
                                  destination: agreement.dropDetails.isNotEmpty ? agreement.dropDetails : (agreement.destinationCity ?? ''),
                                );
                              },
                              icon: const Icon(Icons.map_rounded, size: 18),
                              label: Text(
                                s.viewRouteInMapsButton,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildPartyCard({
    required String roleLabel,
    required String partyName,
    required IconData icon,
    required String subInfo,
    required bool isConfirmed,
    required String confirmedStamp,
    required String pendingStamp,
    required bool isMe,
    required AppStrings s,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConfirmed ? Colors.green.shade300 : const Color(0xFFE2E8F0),
          width: isConfirmed ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleLabel,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$partyName ${isMe ? (s.isHindi ? "(आप)" : "(You)") : ""}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subInfo,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const Divider(height: 18, thickness: 0.7),
          // Signature / Confirmation Stamp Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isConfirmed ? Colors.green.shade50 : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isConfirmed ? Colors.green.shade400 : Colors.amber.shade400,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConfirmed ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  size: 14,
                  color: isConfirmed ? Colors.green.shade800 : Colors.amber.shade900,
                ),
                const SizedBox(width: 6),
                Text(
                  isConfirmed ? confirmedStamp : pendingStamp,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isConfirmed ? Colors.green.shade900 : Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color iconColor = AppTheme.textMuted,
    bool highlightValue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: highlightValue ? FontWeight.w800 : FontWeight.w600,
              color: highlightValue ? AppTheme.primaryGreen : AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
