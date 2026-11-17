import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.errorAuthFailed}: ${err.toString()}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon / Logo Emblem
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      size: 44,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Brand Title
                  const Text(
                    AppStrings.appNameHindi,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  const Text(
                    AppStrings.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Purpose Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          AppStrings.loginTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppStrings.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Google Sign-In Action
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.textDark,
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.signInWithGoogle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Local Preview / Demo Mode Bypass Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'या स्थानीय परीक्षण (Demo Mode)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Demo Driver Bypass
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).signInAsDemoUser(asDriver: true),
                    icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                    label: const Text(
                      'डेमो मोड: चालक (Driver) के रूप में प्रवेश',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Demo Rider Bypass
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).signInAsDemoUser(asDriver: false),
                    icon: const Icon(Icons.person_search_rounded, color: AppTheme.accentAmber),
                    label: const Text(
                      'डेमो मोड: यात्री (Rider) के रूप में प्रवेश',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.accentAmber),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentAmber, width: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
