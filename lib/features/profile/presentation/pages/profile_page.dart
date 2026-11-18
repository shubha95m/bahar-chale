import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/app_bottom_bar.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final langNotifier = ref.read(appLanguageProvider.notifier);

    final user = ref.watch(currentUserProvider);
    final isDriver = user?.email == 'demo@baharchale.local';
    final meta = user?.userMetadata;
    final name = (meta?['full_name'] as String?) ??
        (meta?['name'] as String?) ??
        user?.email?.split('@').first ??
        (s.isHindi ? 'यात्री' : 'Traveler');
    final avatarUrl = (meta?['avatar_url'] as String?) ?? (meta?['picture'] as String?);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.navProfileText),
        actions: const [
          LanguageSwitcherButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'य',
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
                              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDriver ? AppTheme.primaryGreen.withOpacity(0.1) : AppTheme.accentAmber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isDriver ? 'सत्यापित चालक (Driver)' : 'सत्यापित यात्री (Rider)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDriver ? AppTheme.primaryGreen : AppTheme.accentAmber,
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

                // Quick Testing Switcher Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'त्वरित परीक्षण खाता बदलें (Switch Demo Role)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isDriver ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.white,
                                minimumSize: const Size.fromHeight(40),
                              ),
                              onPressed: isDriver
                                  ? null
                                  : () async {
                                      await ref.read(authControllerProvider.notifier).signInAsDemoUser(asDriver: true);
                                    },
                              child: const Text('राहुल शर्मा (चालक)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: !isDriver ? AppTheme.accentAmber.withOpacity(0.1) : Colors.white,
                                minimumSize: const Size.fromHeight(40),
                              ),
                              onPressed: !isDriver
                                  ? null
                                  : () async {
                                      await ref.read(authControllerProvider.notifier).signInAsDemoUser(asDriver: false);
                                    },
                              child: const Text('अमित कुमार (यात्री)'),
                            ),
                          ),
                        ],
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
                      const ListTile(
                        leading: Icon(Icons.security_rounded, color: AppTheme.primaryGreen),
                        title: Text('डेटा गोपनीयता व सुरक्षा'),
                        subtitle: Text('100% RLS एन्क्रिप्टेड क्लाउड डेटाबेस'),
                        trailing: Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen),
                        title: Text('संस्करण (Version)'),
                        trailing: Text('v0.2.0 (Pilot)', style: TextStyle(color: AppTheme.textMuted)),
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
                        title: const Text(AppStrings.logout),
                        content: const Text(AppStrings.logoutConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text(AppStrings.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(AppStrings.logout),
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
                  label: const Text(AppStrings.logout, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomBar(currentIndex: 4),
    );
  }
}
