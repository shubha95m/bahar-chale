import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/authentication/presentation/providers/auth_provider.dart';
import 'package:bahar_chale/features/chat/presentation/providers/chat_provider.dart';
import 'package:bahar_chale/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:bahar_chale/features/requests/domain/entities/passenger_request.dart';
import 'package:bahar_chale/features/requests/presentation/providers/passenger_requests_provider.dart';
import 'package:bahar_chale/features/rides/domain/entities/ride.dart';
import 'package:bahar_chale/features/rides/presentation/pages/search_rides_page.dart';
import 'package:bahar_chale/features/rides/presentation/providers/rides_provider.dart';

void main() {
  testWidgets('SearchRidesPage renders universal search bar, filter chips and popular routes', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          allAvailableRidesProvider.overrideWith((ref, filter) => Stream.value(<Ride>[])),
          allOpenPassengerRequestsProvider.overrideWith((ref, filter) => Stream.value(<PassengerRequest>[])),
          unreadConversationsCountProvider.overrideWith((ref) => Stream.value(0)),
          unreadNotificationsCountProvider.overrideWithValue(const AsyncValue.data(0)),
        ],
        child: const MaterialApp(
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
