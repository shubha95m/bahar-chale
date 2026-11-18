import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';

class CancellationWarningDialog extends StatelessWidget {
  final AppStrings s;
  final String title;
  final String tripDescription;
  final bool hasLinkedTravelers;
  final int linkedTravelersCount;
  final String role; // 'driver' or 'passenger'
  final int remainingCancellations; // out of 3

  const CancellationWarningDialog({
    super.key,
    required this.s,
    required this.title,
    required this.tripDescription,
    this.hasLinkedTravelers = false,
    this.linkedTravelersCount = 0,
    this.role = 'driver',
    this.remainingCancellations = 2,
  });

  /// Displays the standardized, policy-compliant cancellation dialog.
  /// Returns `true` if user confirms cancellation, `false` otherwise.
  static Future<bool> show(
    BuildContext context, {
    required AppStrings s,
    required String title,
    required String tripDescription,
    bool hasLinkedTravelers = false,
    int linkedTravelersCount = 0,
    String role = 'driver',
    int remainingCancellations = 2,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CancellationWarningDialog(
        s: s,
        title: title,
        tripDescription: tripDescription,
        hasLinkedTravelers: hasLinkedTravelers,
        linkedTravelersCount: linkedTravelersCount,
        role: role,
        remainingCancellations: remainingCancellations,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = s.isHindi;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Icon Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        if (tripDescription.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            tripDescription,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. Linked Travelers Notification Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasLinkedTravelers ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasLinkedTravelers ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      hasLinkedTravelers ? Icons.notifications_active_rounded : Icons.info_outline_rounded,
                      color: hasLinkedTravelers ? Colors.amber.shade900 : const Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasLinkedTravelers
                                ? (isHindi
                                    ? 'सहयात्री जुड़े हुए हैं (Notification will be sent)'
                                    : 'Co-travelers are linked to this trip')
                                : (isHindi ? 'यात्रा विवरण सूचना' : 'Travel Update Notice'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: hasLinkedTravelers ? Colors.amber.shade900 : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasLinkedTravelers
                                ? (isHindi
                                    ? 'इस यात्रा से यात्री/चालक जुड़े हुए हैं। रद्द करने पर उन्हें तुरंत नोटिफिकेशन भेजा जाएगा ताकि वे अन्य विकल्पों की व्यवस्था कर सकें।'
                                    : 'Co-travelers are linked. Cancelling will automatically send an instant notification to all affected parties so they can arrange alternate travel.')
                                : (isHindi
                                    ? 'यह यात्रा आपके शेड्यूल से हटा दी जाएगी।'
                                    : 'This trip itinerary will be permanently removed from your active schedule.'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF475569),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Cancellation Policy & Account Suspension Warning
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isHindi ? 'मासिक रद्दीकरण नीति (Fair Policy)' : 'Monthly Cancellation Policy',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isHindi
                          ? '• समुदाय में विश्वसनीयता बनाए रखने के लिए प्रति माह अधिकतम 3 रद्दीकरण की अनुमति है।\n• चेतावनी: इस महीने आपके पास केवल $remainingCancellations और रद्दीकरण शेष हैं (Only $remainingCancellations more allowed).\n• लगातार या अत्यधिक रद्दीकरण करने पर आपका खाता 1 महीने के लिए अस्थायी रूप से ब्लॉक/निलंबित किया जा सकता है।'
                          : '• Maximum 3 cancellations are allowed per month to maintain platform reliability.\n• Notice: You are only allowed $remainingCancellations more cancellations this month.\n• Frequent cancellations may lead to a temporary 1-month account suspension.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade900.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        isHindi ? 'नहीं, रखें' : 'No, Keep Trip',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, size: 18),
                      label: Text(
                        isHindi ? 'हां, रद्द करें' : 'Confirm Cancel',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
