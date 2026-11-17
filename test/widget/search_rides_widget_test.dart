import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/localization/app_strings.dart';
import 'package:bahar_chale/features/rides/presentation/pages/search_rides_page.dart';

void main() {
  testWidgets('SearchRidesPage renders search bar and empty instructions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SearchRidesPage(),
        ),
      ),
    );

    // Verify search page header and initial guidance
    expect(find.text('सवारी खोजें'), findsWidgets);
    expect(find.text(AppStrings.originCity), findsOneWidget);
    expect(find.text(AppStrings.destinationCity), findsOneWidget);
    expect(find.text('सवारी खोजने के लिए विवरण दर्ज करें'), findsOneWidget);
  });
}
