import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  hindi('hi', 'हिंदी', 'Hindi'),
  english('en', 'English', 'English');

  final String code;
  final String nativeName;
  final String englishName;

  const AppLanguage(this.code, this.nativeName, this.englishName);

  static AppLanguage fromCode(String? code) {
    if (code == 'en') return AppLanguage.english;
    return AppLanguage.hindi;
  }
}

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _prefKey = 'app_language';

  AppLanguageNotifier({AppLanguage? initialLanguage})
      : super(initialLanguage ?? AppLanguage.hindi) {
    if (initialLanguage == null) {
      _loadSavedLanguage();
    }
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) {
        state = AppLanguage.fromCode(code);
      }
    } catch (_) {
      // Default to Hindi on storage failure
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final next = state == AppLanguage.hindi ? AppLanguage.english : AppLanguage.hindi;
    await setLanguage(next);
  }
}

final appLanguageProvider = StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
  return AppLanguageNotifier();
});
