import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String defaultUrl = 'https://iswbhvtosueavuzavtbr.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlzd2JodnRvc3VlYXZ1emF2dGJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ5MTc3NDgsImV4cCI6MjExMDQ5Mzc0OH0.txdBKwmldUxcVtUDB6Q2YVAwLNefynPtUuTZihT2Jq0';

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Notice: .env asset not present. Using production configuration.');
    }

    String? envUrl;
    String? envAnonKey;
    if (dotenv.isInitialized) {
      envUrl = dotenv.maybeGet('SUPABASE_URL');
      envAnonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');
    }

    final supabaseUrl = envUrl ??
        const String.fromEnvironment('SUPABASE_URL', defaultValue: defaultUrl);
    final supabaseAnonKey = envAnonKey ??
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: defaultAnonKey);

    await Supabase.initialize(
      url: supabaseUrl.isNotEmpty ? supabaseUrl : defaultUrl,
      anonKey: supabaseAnonKey.isNotEmpty ? supabaseAnonKey : defaultAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
