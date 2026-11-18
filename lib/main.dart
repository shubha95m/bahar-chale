import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/configuration/supabase_config.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/database/local_database.dart';
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

  runApp(
    const ProviderScope(
      child: BaharChaleApp(),
    ),
  );
}

class BaharChaleApp extends ConsumerWidget {
  const BaharChaleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appNameHindi,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
