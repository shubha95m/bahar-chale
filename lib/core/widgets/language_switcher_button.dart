import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_theme.dart';
import '../localization/app_language.dart';

class LanguageSwitcherButton extends ConsumerWidget {
  final bool isCompact;

  const LanguageSwitcherButton({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);
    final notifier = ref.read(appLanguageProvider.notifier);

    return PopupMenuButton<AppLanguage>(
      tooltip: currentLang == AppLanguage.hindi ? 'भाषा बदलें (Change Language)' : 'Change Language',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language_rounded, size: 16, color: AppTheme.primaryGreen),
            if (!isCompact) ...[
              const SizedBox(width: 4),
              Text(
                currentLang == AppLanguage.hindi ? 'हिन्दी' : 'EN',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppTheme.primaryGreen),
            ],
          ],
        ),
      ),
      onSelected: (AppLanguage lang) {
        notifier.setLanguage(lang);
      },
      itemBuilder: (BuildContext ctx) => [
        PopupMenuItem(
          value: AppLanguage.hindi,
          child: Row(
            children: [
              Text(
                'हिंदी (Hindi)',
                style: TextStyle(
                  fontWeight: currentLang == AppLanguage.hindi ? FontWeight.bold : FontWeight.normal,
                  color: currentLang == AppLanguage.hindi ? AppTheme.primaryGreen : AppTheme.textDark,
                ),
              ),
              if (currentLang == AppLanguage.hindi) ...[
                const Spacer(),
                const Icon(Icons.check_rounded, color: AppTheme.primaryGreen, size: 18),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: AppLanguage.english,
          child: Row(
            children: [
              Text(
                'English',
                style: TextStyle(
                  fontWeight: currentLang == AppLanguage.english ? FontWeight.bold : FontWeight.normal,
                  color: currentLang == AppLanguage.english ? AppTheme.primaryGreen : AppTheme.textDark,
                ),
              ),
              if (currentLang == AppLanguage.english) ...[
                const Spacer(),
                const Icon(Icons.check_rounded, color: AppTheme.primaryGreen, size: 18),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
