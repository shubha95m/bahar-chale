import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utilities/map_launcher.dart';
import '../providers/agreement_provider.dart';

class AgreementPage extends ConsumerWidget {
  final String requestId;

  const AgreementPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementAsync = ref.watch(agreementByRequestProvider(requestId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('यात्रा समन्वय (Travel Agreement)'),
        actions: [
          IconButton(
            tooltip: 'बातचीत (Chat)',
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryGreen),
            onPressed: () => context.push('/chat/$requestId'),
          ),
        ],
      ),
      body: agreementAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('समझौता लोड करने में समस्या। कृपया पुनः प्रयास करें।', style: TextStyle(color: AppTheme.textMuted)),
          ),
        ),
        data: (agreement) {
          if (agreement == null) {
            return const Center(child: Text('इस अनुरोध के लिए कोई यात्रा व्यवस्था नहीं मिली।'));
          }

          final isConfirmed = agreement.status == 'confirmed' || agreement.isFullyConfirmed;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Badge Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isConfirmed ? Colors.green.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isConfirmed ? Colors.green.shade300 : Colors.amber.shade400,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isConfirmed ? Icons.check_circle_rounded : Icons.pending_rounded,
                            color: isConfirmed ? Colors.green.shade700 : Colors.amber.shade800,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConfirmed ? 'यात्रा व्यवस्था पुष्टित है!' : 'पारस्परिक पुष्टि प्रतीक्षित है',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isConfirmed ? Colors.green.shade900 : Colors.amber.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isConfirmed
                                      ? 'दोनों पक्षों ने यात्रा विवरण की पुष्टि कर दी है।'
                                      : 'सुरक्षित यात्रा के लिए दोनों पक्षों की पुष्टि आवश्यक है।',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isConfirmed ? Colors.green.shade800 : Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Travel Terms Card
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
                          const Text(
                            'निर्धारित यात्रा विवरण',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.place_outlined, 'पिकअप स्थल', agreement.pickupDetails),
                          const SizedBox(height: 14),
                          _buildDetailRow(Icons.flag_outlined, 'ड्रॉप स्थल', agreement.dropDetails),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            Icons.calendar_month_rounded,
                            'तारीख व समय',
                            '${DateFormat('dd MMM yyyy').format(agreement.agreedDate)} ${agreement.agreedTime ?? '(लचीला)'}',
                          ),
                          if (agreement.agreedContribution != null) ...[
                            const SizedBox(height: 14),
                            _buildDetailRow(
                              Icons.currency_rupee_rounded,
                              'सहयोग राशि',
                              '₹${agreement.agreedContribution!.toStringAsFixed(0)}',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dual Confirmation Status Check
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'पुष्टि स्थिति (Mutual Confirmation)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          _buildConfirmationRow(
                            title: 'चालक की पुष्टि (Driver)',
                            isConfirmed: agreement.ownerConfirmed,
                          ),
                          const SizedBox(height: 8),
                          _buildConfirmationRow(
                            title: 'यात्री की पुष्टि (Passenger)',
                            isConfirmed: agreement.requesterConfirmed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action 1: Confirm Agreement Button
                    ElevatedButton(
                      onPressed: () async {
                        final success = await ref.read(agreementNotifierProvider.notifier).confirm(agreement.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'पुष्टि सफलतापूर्वक दर्ज की गई!' : 'पुष्टि विफल।'),
                              backgroundColor: success ? AppTheme.primaryGreen : Colors.red,
                            ),
                          );
                          ref.invalidate(agreementByRequestProvider(requestId));
                        }
                      },
                      child: const Text('मेरी ओर से पुष्टि करें (Confirm Arrangement)'),
                    ),
                    const SizedBox(height: 12),

                    // Action 2: Chat Button
                    OutlinedButton.icon(
                      onPressed: () => context.push('/chat/$requestId'),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                      label: const Text('चालक / यात्री से बातचीत करें (Chat)'),
                    ),
                    const SizedBox(height: 12),

                    // Action 3: Open in Google Maps
                    OutlinedButton.icon(
                      onPressed: () {
                        MapLauncher.openDirections(
                          origin: agreement.pickupDetails,
                          destination: agreement.dropDetails,
                        );
                      },
                      icon: const Icon(Icons.map_rounded, size: 20),
                      label: const Text(AppStrings.openMap),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationRow({required String title, required bool isConfirmed}) {
    return Row(
      children: [
        Icon(
          isConfirmed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isConfirmed ? Colors.green : AppTheme.textMuted,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isConfirmed ? FontWeight.bold : FontWeight.normal,
              color: isConfirmed ? Colors.green.shade900 : AppTheme.textDark,
            ),
          ),
        ),
        Text(
          isConfirmed ? 'पूर्ण ✓' : 'लंबित',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isConfirmed ? Colors.green : Colors.orange.shade800,
          ),
        ),
      ],
    );
  }
}
