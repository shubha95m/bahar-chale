import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/app_bottom_bar.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../../core/providers/app_version_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static String formatUserName(dynamic user, {required bool isHindi}) {
    final meta = user?.userMetadata;
    final fullName = (meta?['full_name'] as String?) ?? (meta?['name'] as String?);
    if (fullName != null && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }
    final email = user?.email as String?;
    if (email != null && email.contains('@')) {
      final prefix = email.split('@').first;
      final parts = prefix.split(RegExp(r'[._-]')).where((p) => p.isNotEmpty);
      if (parts.isNotEmpty) {
        return parts.map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
      }
      return prefix;
    }
    return isHindi ? 'सम्मानित यात्री' : 'Valued Traveler';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final langNotifier = ref.read(appLanguageProvider.notifier);
    final versionAsync = ref.watch(appVersionProvider);
    final versionText = versionAsync.value ?? 'v1.0.1 (Build 2)';

    final user = ref.watch(currentUserProvider);
    final meta = user?.userMetadata;
    final profileData = ref.watch(userProfileProvider).valueOrNull;
    final name = (profileData?['display_name'] as String?)?.isNotEmpty == true
        ? (profileData!['display_name'] as String)
        : formatUserName(user, isHindi: s.isHindi);
    final avatarUrl = (profileData?['avatar_url'] as String?) ??
        (meta?['avatar_url'] as String?) ??
        (meta?['picture'] as String?);
    final isIdVerified = profileData?['id_verified'] == true;
    final idType = profileData?['id_type'] as String?;
    final idMasked = profileData?['id_number_masked'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(s.navProfileText),
        actions: const [
          LanguageSwitcherButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 90),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Avatar & Name Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
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
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl == null
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : (s.isHindi ? 'य' : 'U'),
                                  style: const TextStyle(fontSize: 26, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isIdVerified ? Colors.green.shade50 : AppTheme.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: isIdVerified ? Border.all(color: Colors.green.shade200) : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isIdVerified ? Icons.verified_user_rounded : Icons.check_circle_outline,
                                      size: 13,
                                      color: isIdVerified ? Colors.green.shade700 : AppTheme.primaryGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isIdVerified
                                          ? (s.isHindi
                                              ? 'सत्यापित नागरिक (${idType?.toUpperCase() ?? "ID"})'
                                              : 'Verified Citizen (${idType?.toUpperCase() ?? "ID"})')
                                          : (s.isHindi ? 'सत्यापित सदस्य' : 'Verified Member'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isIdVerified ? Colors.green.shade700 : AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reliability & Government ID Verification Card (Responsive & Un-squished)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isIdVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isIdVerified ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header Row: Icon + Title + Status Chip
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isIdVerified ? Colors.green.shade100 : Colors.amber.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isIdVerified ? Icons.verified_user_rounded : Icons.shield_outlined,
                                color: isIdVerified ? Colors.green.shade800 : Colors.amber.shade900,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isIdVerified
                                    ? (s.isHindi ? 'नागरिक विश्वसनीयता सत्यापन' : 'Reliability Verification')
                                    : (s.isHindi ? 'विश्वसनीयता सत्यापन (लंबित)' : 'Reliability Verification (Pending)'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: isIdVerified ? Colors.green.shade900 : Colors.amber.shade900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: isIdVerified ? Colors.green.shade600 : Colors.amber.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isIdVerified ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isIdVerified
                                        ? (s.isHindi ? 'पूर्ण (Done)' : 'Done')
                                        : (s.isHindi ? 'लंबित (Pending)' : 'Pending'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Body description
                        if (isIdVerified) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.badge_outlined, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  '${idType?.toUpperCase() ?? "GOVT ID"}: $idMasked',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.green.shade900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.isHindi
                                ? '✓ आपकी पहचान व प्रोफ़ाइल सत्यापित है। सहयात्री व चालक आप पर पूर्ण विश्वास कर सकते हैं।'
                                : '✓ Your identity and profile photo are verified. Co-travelers and drivers can travel with you with 100% trust.',
                            style: TextStyle(fontSize: 12.5, color: Colors.green.shade800, height: 1.35),
                          ),
                        ] else ...[
                          Text(
                            s.isHindi
                                ? 'सुरक्षित यात्रा व आपसी विश्वास हेतु अपना सरकारी पहचान पत्र (आधार कार्ड, पैन कार्ड या ड्राइविंग लाइसेंस) सत्यापित करें।'
                                : 'Verify your Indian Government ID (Aadhaar, PAN, or Driving License) to earn verified community trust.',
                            style: TextStyle(fontSize: 12.5, color: Colors.amber.shade900, height: 1.35),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/verify-id'),
                              icon: const Icon(Icons.verified_user_rounded, size: 16),
                              label: Text(
                                s.isHindi
                                    ? 'पहचान सत्यापन पूरा करें (Aadhaar / PAN / DL)'
                                    : 'Complete ID Verification (Aadhaar / PAN / DL)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Information List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language_rounded, color: AppTheme.primaryGreen),
                          title: Text(s.interfaceLanguageText),
                          subtitle: Text(currentLang == AppLanguage.hindi ? 'वर्तमान: हिंदी' : 'Current: English'),
                          trailing: SegmentedButton<AppLanguage>(
                            segments: const [
                              ButtonSegment(
                                value: AppLanguage.hindi,
                                label: Text('हिन्दी', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              ButtonSegment(
                                value: AppLanguage.english,
                                label: Text('EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            selected: {currentLang},
                            onSelectionChanged: (newSelection) {
                              langNotifier.setLanguage(newSelection.first);
                            },
                            showSelectedIcon: false,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.description_outlined, color: AppTheme.primaryGreen),
                          title: Text(s.isHindi ? 'नियम व शर्तें (Terms & Conditions)' : 'Terms & Conditions'),
                          subtitle: Text(s.isHindi ? 'आईटी एक्ट 2000 व मोटर वाहन अधिनियम' : 'IT Act 2000 & Motor Vehicles Act'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                          onTap: () => context.push('/terms'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryGreen),
                          title: Text(s.isHindi ? 'गोपनीयता नीति (Privacy Policy)' : 'Privacy Policy'),
                          subtitle: Text(s.isHindi ? 'डीपीडीपी अधिनियम 2023 (DPDP Act)' : 'DPDP Act 2023 Compliant'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                          onTap: () => context.push('/privacy'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.security_rounded, color: AppTheme.primaryGreen),
                          title: Text(s.isHindi ? 'डेटा गोपनीयता व सुरक्षा' : 'Data Privacy & Security'),
                          subtitle: Text(s.isHindi ? '100% RLS एन्क्रिप्टेड क्लाउड डेटाबेस' : '100% RLS Encrypted Cloud Database'),
                          trailing: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.volunteer_activism_rounded, color: AppTheme.primaryGreen),
                          title: Text(s.isHindi ? 'शून्य लागत सामुदायिक यात्रा' : 'Zero Cost Community Travel'),
                          subtitle: Text(s.isHindi ? 'गैर-व्यावसायिक आपसी सहायता प्लेटफॉर्म' : 'Non-commercial mutual assistance platform'),
                          trailing: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen),
                          title: Text(s.isHindi ? 'संस्करण (Version)' : 'Version'),
                          trailing: Text(versionText, style: const TextStyle(color: AppTheme.textMuted)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Action
                  OutlinedButton.icon(
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
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: Text(s.logoutText, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Danger Zone: Remove / Delete Account
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              s.isHindi ? 'खाता प्रबंधन (Danger Zone)' : 'Danger Zone',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.red.shade900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.isHindi
                              ? 'खाता हटाने पर आपका प्रोफाइल निलंबित हो जाएगा और सक्रिय राइड्स रद्द हो जाएंगी। भविष्य में इसी ईमेल से नया साइन अप कर सकेंगे।'
                              : 'Removing your account will suspend your profile and cancel active rides. You may register fresh in the future using this email.',
                          style: TextStyle(fontSize: 12, color: Colors.red.shade800, height: 1.35),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(s.isHindi ? 'खाता हटाएं / निलंबित करें?' : 'Delete / Suspend Account?'),
                                content: Text(
                                  s.isHindi
                                      ? 'क्या आप वाकई अपना खाता हटाना चाहते हैं?\n\n• आपकी सभी सक्रिय राइड्स और अनुरोध रद्द हो जाएंगे।\n• आपका खाता निष्क्रिय/निलंबित कर दिया जाएगा।\n• भविष्य में इसी ईमेल से आप पुनः नया खाता बना सकेंगे।'
                                      : 'Are you sure you want to remove your account?\n\n• All your active rides and requests will be cancelled.\n• Your profile will be marked inactive.\n• If you return in the future, you can sign up again fresh with this email.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(s.cancelText),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(
                                      s.isHindi ? 'हाँ, खाता हटाएं' : 'Yes, Delete Account',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final success = await ref.read(authControllerProvider.notifier).removeAccount();
                              if (context.mounted) {
                                if (success) {
                                  context.go('/login');
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 18),
                          label: Text(
                            s.isHindi ? 'खाता हटाएं (Delete Account)' : 'Delete Account',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomBar(currentIndex: 4),
    );
  }
}
