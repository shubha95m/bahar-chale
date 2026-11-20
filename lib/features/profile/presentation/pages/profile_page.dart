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
    final name = formatUserName(user, isHindi: s.isHindi);
    final avatarUrl = (meta?['avatar_url'] as String?) ?? (meta?['picture'] as String?);

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
                                  color: AppTheme.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.isHindi ? 'सत्यापित खाता (Verified)' : 'Verified Member',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

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
                  const SizedBox(height: 32),

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
