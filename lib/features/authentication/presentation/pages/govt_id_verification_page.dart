import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../widgets/govt_id_verification_widget.dart';

class GovtIdVerificationPage extends ConsumerWidget {
  const GovtIdVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = SupabaseConfig.client.auth.currentUser;
    final meta = user?.userMetadata;
    final userName = (meta?['full_name'] as String?) ?? (meta?['name'] as String?) ?? 'Traveler';
    final userId = user?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          s.isHindi ? 'नागरिक पहचान सत्यापन' : 'Citizen ID Verification',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          LanguageSwitcherButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GovtIdVerificationWidget(
                    userId: userId,
                    userName: userName,
                    isStandalone: true,
                    onCompleted: () {
                      context.go('/');
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.textMuted),
                      label: Text(
                        s.isHindi ? 'बाद में सत्यापन करें (Skip to Home for now)' : 'Verify later (Skip to Home for now)',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
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
