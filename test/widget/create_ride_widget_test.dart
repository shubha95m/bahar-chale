import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/localization/app_strings.dart';
import 'package:bahar_chale/features/authentication/presentation/providers/auth_provider.dart';
import 'package:bahar_chale/features/rides/domain/entities/ride.dart';
import 'package:bahar_chale/features/rides/presentation/pages/create_ride_page.dart';
import 'package:bahar_chale/features/rides/presentation/providers/rides_provider.dart';

class FakeCreateRideNotifier extends StateNotifier<AsyncValue<Ride?>> implements CreateRideNotifier {
  FakeCreateRideNotifier() : super(const AsyncValue.data(null));

  @override
  Future<Ride?> submitRide(Ride ride) async {
    return ride;
  }
}

void main() {
  testWidgets('CreateRidePage renders category toggles and input fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          createRideNotifierProvider.overrideWith((ref) => FakeCreateRideNotifier()),
        ],
        child: const MaterialApp(
          home: CreateRidePage(),
        ),
      ),
    );

    // Verify title and main labels
    expect(find.text('सवारी प्रकाशित करें'), findsOneWidget);
    expect(find.text('निजी वाहन (कार/बाइक)'), findsOneWidget);
    expect(find.text('सामान्य यात्रा'), findsOneWidget);
    expect(find.text(AppStrings.flexibleTime), findsOneWidget);
    expect(find.text(AppStrings.totalSeats), findsOneWidget);
    expect(find.text('सवारी साझा करें'), findsOneWidget);
  });
}
