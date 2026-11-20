import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/authentication/presentation/widgets/verification_success_dialog.dart';

void main() {
  testWidgets('VerificationSuccessDialog renders celebratory contents and cross icon', (tester) async {
    bool dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                VerificationSuccessDialog.show(
                  context,
                  userName: 'Shubham',
                  idType: 'aadhaar',
                  maskedIdNumber: 'XXXX XXXX 5212',
                  isHindi: false,
                  onDismiss: () {
                    dismissed = true;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('🎉 Congratulations! Verified Successfully'), findsOneWidget);
    expect(find.text('Hello Shubham, your profile and Government ID have been verified successfully.'), findsOneWidget);
    expect(find.text('XXXX XXXX 5212'), findsOneWidget);
    expect(find.text('Start Travelling'), findsOneWidget);

    // Verify top-right cross icon
    final closeIcon = find.byIcon(Icons.close_rounded);
    expect(closeIcon, findsOneWidget);

    // Tap cross icon to dismiss
    await tester.tap(closeIcon);
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
  });
}
