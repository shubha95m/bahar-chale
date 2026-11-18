import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/localization/app_language.dart';
import 'package:bahar_chale/core/localization/app_strings.dart';
import 'package:bahar_chale/features/rides/presentation/widgets/cancellation_warning_dialog.dart';

void main() {
  group('CancellationWarningDialog & Policy Tests', () {
    testWidgets('Cancellation dialog renders linked travelers warning and 2 remaining cancellations', (tester) async {
      const strings = AppStrings(AppLanguage.hindi);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => CancellationWarningDialog.show(
                  context,
                  s: strings,
                  title: 'सवारी रद्द / हटाएं?',
                  tripDescription: 'पुणे → मुंबई',
                  hasLinkedTravelers: true,
                  linkedTravelersCount: 2,
                  role: 'driver',
                  remainingCancellations: 2,
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify title & route
      expect(find.text('सवारी रद्द / हटाएं?'), findsOneWidget);
      expect(find.text('पुणे → मुंबई'), findsOneWidget);

      // Verify linked travelers warning is visible
      expect(find.textContaining('सहयात्री जुड़े हुए हैं'), findsOneWidget);

      // Verify monthly cancellation policy & remaining count
      expect(find.textContaining('मासिक रद्दीकरण नीति'), findsOneWidget);
      expect(find.textContaining('केवल 2 और रद्दीकरण शेष हैं'), findsOneWidget);

      // Verify action buttons
      expect(find.text('नहीं, रखें'), findsOneWidget);
      expect(find.text('हां, रद्द करें'), findsOneWidget);

      // Tap dismiss
      await tester.tap(find.text('नहीं, रखें'));
      await tester.pumpAndSettle();

      expect(find.byType(CancellationWarningDialog), findsNothing);
    });

    testWidgets('Cancellation dialog renders clean English when English is selected', (tester) async {
      const strings = AppStrings(AppLanguage.english);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => CancellationWarningDialog.show(
                  context,
                  s: strings,
                  title: 'Cancel Ride?',
                  tripDescription: 'Delhi → Jaipur',
                  hasLinkedTravelers: true,
                  linkedTravelersCount: 1,
                  role: 'driver',
                  remainingCancellations: 2,
                ),
                child: const Text('Show Dialog EN'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog EN'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Ride?'), findsOneWidget);
      expect(find.text('Co-travelers are linked to this trip'), findsOneWidget);
      expect(find.textContaining('Monthly Cancellation Policy'), findsOneWidget);
      expect(find.textContaining('allowed 2 more cancellations this month'), findsOneWidget);
      expect(find.text('No, Keep Trip'), findsOneWidget);
      expect(find.text('Confirm Cancel'), findsOneWidget);
    });
  });
}
