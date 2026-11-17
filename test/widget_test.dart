import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/localization/app_strings.dart';
import 'package:bahar_chale/features/authentication/presentation/pages/login_page.dart';

void main() {
  test('AppStrings localization catalog verification', () {
    expect(AppStrings.appNameHindi, 'बाहर चलें');
    expect(AppStrings.tagline, 'सफर साथ में, आसान हर राह।');
    expect(AppStrings.actionWantRide, 'मुझे यात्रा करनी है');
    expect(AppStrings.actionGiveRide, 'मैं साथ ले जा सकता हूँ');
  });

  testWidgets('LoginPage renders brand identity and Google Sign-In action', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Verify brand name & tagline
    expect(find.text(AppStrings.appNameHindi), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
    expect(find.text(AppStrings.signInWithGoogle), findsOneWidget);
  });
}
