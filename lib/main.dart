import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/configuration/supabase_config.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/database/local_database.dart';
import 'core/localization/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase from .env
  await SupabaseConfig.initialize();

  // Initialize local SQLite cache
  await LocalDatabase.instance;

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
