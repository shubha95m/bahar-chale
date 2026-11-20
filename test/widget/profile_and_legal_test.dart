import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/localization/app_language.dart';
import 'package:bahar_chale/features/legal/presentation/pages/terms_page.dart';
import 'package:bahar_chale/features/legal/presentation/pages/privacy_page.dart';

void main() {
  testWidgets('TermsPage renders legal headers and sections cleanly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguageNotifier(initialLanguage: AppLanguage.english)),
        ],
        child: const MaterialApp(
          home: TermsPage(),
        ),
      ),
    );

    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Bahar Chale Terms of Service'), findsOneWidget);
    expect(find.text('1. Nature of Platform & Intermediary Status'), findsOneWidget);
    expect(find.text('3. Citizen Reliability & Government ID Verification System'), findsOneWidget);
  });

  testWidgets('PrivacyPage renders DPDP Act 2023 sections cleanly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguageNotifier(initialLanguage: AppLanguage.english)),
        ],
        child: const MaterialApp(
          home: PrivacyPage(),
        ),
      ),
    );

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Bahar Chale Privacy Policy'), findsOneWidget);
    expect(find.text('Digital Personal Data Protection Act 2023 Compliant'), findsOneWidget);
    expect(find.text('3. Government ID Verification & Algorithmic Security'), findsOneWidget);
  });
}
