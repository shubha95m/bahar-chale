import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/rides/presentation/pages/search_rides_page.dart';

void main() {
  testWidgets('SearchRidesPage renders universal search bar, filter chips and popular routes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SearchRidesPage(),
        ),
      ),
    );

    // Verify search page header and fast filters
    expect(find.textContaining('सवारियां खोजें'), findsWidgets);
    expect(find.text('सभी वाहन'), findsOneWidget);
    expect(find.text('कार (Car)'), findsOneWidget);
    expect(find.text('बाइक (Bike)'), findsOneWidget);
    expect(find.text('पुणे ➔ मुंबई'), findsOneWidget);
  });
}
