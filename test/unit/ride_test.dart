import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/rides/domain/entities/ride.dart';
import 'package:bahar_chale/features/rides/presentation/providers/rides_provider.dart';

void main() {
  group('Ride Model & Business Logic', () {
    test('Ride routeDisplay formats origin and destination areas correctly', () {
      final rideWithAreas = Ride(
        id: '123',
        ownerId: 'user-1',
        rideCategory: 'private_vehicle',
        vehicleType: 'car',
        originCity: 'Pune',
        originArea: 'Hinjawadi',
        destinationCity: 'Mumbai',
        destinationArea: 'Dadar',
        travelDate: DateTime(2026, 11, 20),
        totalSeats: 3,
        availableSeats: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(rideWithAreas.routeDisplay, 'Pune (Hinjawadi) → Mumbai (Dadar)');

      final rideWithoutAreas = Ride(
        id: '124',
        ownerId: 'user-1',
        rideCategory: 'general_travel',
        originCity: 'Nashik',
        destinationCity: 'Pune',
        travelDate: DateTime(2026, 11, 22),
        totalSeats: 2,
        availableSeats: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(rideWithoutAreas.routeDisplay, 'Nashik → Pune');
    });

    test('Ride toMap and fromMap serialization integrity', () {
      final original = Ride(
        id: 'test-uuid-1',
        ownerId: 'user-123',
        rideCategory: 'private_vehicle',
        vehicleType: 'car',
        originCity: 'Pune',
        originArea: 'Wakad',
        destinationCity: 'Goa',
        destinationArea: 'Panjim',
        travelDate: DateTime(2026, 12, 1),
        travelTime: '06:00:00',
        isTimeFlexible: true,
        totalSeats: 4,
        availableSeats: 4,
        contributionAmount: 500.0,
        notes: 'No smoking please',
        status: 'open',
        createdAt: DateTime.parse('2026-11-17T12:00:00Z'),
        updatedAt: DateTime.parse('2026-11-17T12:00:00Z'),
      );

      final map = original.toMap();
      expect(map['id'], 'test-uuid-1');
      expect(map['origin_city'], 'Pune');
      expect(map['travel_date'], '2026-12-01');

      final reconstructed = Ride.fromMap(map, ownerName: 'राहुल शर्मा');
      expect(reconstructed.id, original.id);
      expect(reconstructed.originCity, original.originCity);
      expect(reconstructed.ownerName, 'राहुल शर्मा');
      expect(reconstructed.contributionAmount, 500.0);
    });

    test('SearchParams normalizes city case and whitespace for query equivalence', () {
      final param1 = SearchParams(
        originCity: 'Pune ',
        destinationCity: 'mumbai',
        travelDate: DateTime(2026, 11, 20),
      );

      final param2 = SearchParams(
        originCity: 'pune',
        destinationCity: ' Mumbai ',
        travelDate: DateTime(2026, 11, 20),
      );

      expect(param1, equals(param2));
      expect(param1.hashCode, equals(param2.hashCode));
    });
  });
}
