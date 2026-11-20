import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/localization/app_language.dart';
import 'package:bahar_chale/core/localization/app_strings.dart';
import 'package:bahar_chale/features/authentication/presentation/pages/login_page.dart';

void main() {
  test('AppStrings localization catalog verification', () {
    const hindiStrings = AppStrings(AppLanguage.hindi);
    expect(hindiStrings.appTitle, 'बाहर चलें (Bahar Chale)');
    expect(hindiStrings.appTagline, 'सफर साथ में, आसान हर राह।');
    expect(hindiStrings.actionWantRideText, 'मुझे यात्रा करनी है');
    expect(hindiStrings.actionGiveRideText, 'अपनी ड्राइविंग राइड शेयर करें');

    const englishStrings = AppStrings(AppLanguage.english);
    expect(englishStrings.appTitle, 'Bahar Chale');
    expect(englishStrings.appTagline, 'Travel together, make every road easy.');
    expect(englishStrings.actionWantRideText, 'Find a Ride');
    expect(englishStrings.actionGiveRideText, 'Offer a Ride');
  });

  testWidgets('LoginPage renders brand identity and core login actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    const s = AppStrings(AppLanguage.hindi);
    // Verify brand identity and auth tabs
    expect(find.text(s.appTitle), findsOneWidget);
    expect(find.text(s.signInTab), findsOneWidget);
  });
}
