import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/authentication/presentation/widgets/verification_progress_dialog.dart';
import 'package:bahar_chale/features/authentication/presentation/widgets/verification_success_dialog.dart';

void main() {
  testWidgets('VerificationProgressDialog renders reassurance banner and progress bar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VerificationProgressDialog(isHindi: false),
        ),
      ),
    );

    expect(find.text('Verifying Documents in Backend...'), findsOneWidget);
    expect(
      find.text('Please relax! Our secure backend engine is verifying your document authenticity and reliability.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Analyzing document photo clarity & magic bytes...'), findsOneWidget);
  });

  testWidgets('VerificationProgressDialog renders Hindi reassurance correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VerificationProgressDialog(isHindi: true),
        ),
      ),
    );

    expect(find.text('सर्वर पर दस्तावेज़ का सत्यापन हो रहा है...'), findsOneWidget);
    expect(
      find.text('कृपया निश्चिंत रहें! हमारा सुरक्षित बैकएंड इंजन दस्तावेज़ की प्रामाणिकता जांच रहा है।'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

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
