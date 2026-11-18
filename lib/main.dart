import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/configuration/supabase_config.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/database/local_database.dart';
import 'core/localization/app_language.dart';
import 'core/localization/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase safely
  try {
    await SupabaseConfig.initialize();
  } catch (e, st) {
    debugPrint('Supabase initialization error: $e\n$st');
  }

  // Initialize local SQLite cache
  try {
    await LocalDatabase.instance;
  } catch (e, st) {
    debugPrint('LocalDatabase initialization error: $e\n$st');
  }

  // Pre-load saved language synchronously before the first frame paints (avoids any FOUT / language flicker)
  AppLanguage initialLanguage = AppLanguage.hindi;
  try {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language');
    if (code != null) {
      initialLanguage = AppLanguage.fromCode(code);
    } else {
      final sysLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (sysLang.startsWith('en')) {
        initialLanguage = AppLanguage.english;
      }
    }
  } catch (e) {
    debugPrint('Language preload notice: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith(
          (ref) => AppLanguageNotifier(initialLanguage: initialLanguage),
        ),
      ],
      child: const BaharChaleApp(),
    ),
  );
}

class BaharChaleApp extends ConsumerWidget {
  const BaharChaleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final s = ref.watch(stringsProvider);

    return MaterialApp.router(
      title: s.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
