import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import 'govt_id_verification_widget.dart';

class GovtDocumentGateDialog {
  /// Checks whether the user has completed their Government Document Record.
  /// If already recorded, returns `true`.
  /// If not, pops up the mandatory document upload modal and returns `true` only once completed.
  static Future<bool> ensureVerified(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    // Fetch fresh profile state
    final profile = ref.read(userProfileProvider).valueOrNull ??
        await ref.read(userProfileProvider.future).catchError((_) => null);

    if (profile?['id_verified'] == true) {
      return true;
    }

    if (!context.mounted) return false;
    final s = ref.read(stringsProvider);
    final userName = ProfilePage.formatUserName(user, isHindi: s.isHindi);

    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Header with Mandatory Notice
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.badge_outlined, color: AppTheme.primaryGreen, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.isHindi ? 'सरकारी दस्तावेज रिकॉर्ड आवश्यक' : 'Govt Document Record Required',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.isHindi
                                  ? 'आपकी और अन्य सदस्यों की सुरक्षा और विश्वसनीयता के लिए सरकारी दस्तावेज अपलोड करना अनिवार्य है।'
                                  : 'You need to upload Govt Document for reliability and safety for you and other members.',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                        tooltip: s.cancelText,
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ],
                  ),
                ),
                // Scrollable Verification Widget
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: GovtIdVerificationWidget(
                      userId: user.id,
                      userName: userName,
                      isStandalone: true,
                      onCompleted: () {
                        ref.invalidate(userProfileProvider);
                        Navigator.pop(ctx, true);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return completed ?? false;
  }
}
