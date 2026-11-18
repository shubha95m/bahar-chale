import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/requests/domain/entities/passenger_request.dart';

void main() {
  group('PassengerRequest Model & Entity Logic', () {
    test('JSON serialization round-trip maintains all fields', () {
      final json = {
        'id': 'pr-101',
        'requester_id': 'user-abc',
        'origin_city': 'Pune',
        'origin_area': 'Hinjawadi',
        'destination_city': 'Mumbai',
        'destination_area': 'Dadar',
        'travel_date': '2026-11-20',
        'travel_time': 'Morning 08:00',
        'is_time_flexible': true,
        'seats_needed': 2,
        'preferred_vehicle': 'car',
        'notes': 'Luggage with 2 bags',
        'status': 'open',
        'created_at': '2026-11-18T10:00:00Z',
        'profiles': {
          'display_name': 'Aarav Sharma',
          'phone': '9876543210',
          'avatar_url': 'https://example.com/avatar.png',
        },
      };

      final req = PassengerRequest.fromMap(json);

      expect(req.id, equals('pr-101'));
      expect(req.requesterId, equals('user-abc'));
      expect(req.originCity, equals('Pune'));
      expect(req.originArea, equals('Hinjawadi'));
      expect(req.destinationCity, equals('Mumbai'));
      expect(req.destinationArea, equals('Dadar'));
      expect(req.seatsNeeded, equals(2));
      expect(req.preferredVehicle, equals('car'));
      expect(req.notes, equals('Luggage with 2 bags'));
      expect(req.status, equals('open'));
      expect(req.requesterName, equals('Aarav Sharma'));

      // Check helper getters
      expect(req.routeDisplay, equals('Pune (Hinjawadi) ➔ Mumbai (Dadar)'));
      expect(req.vehicleLabel, equals('Car'));
      expect(req.localizedVehicleLabel(isHindi: true), equals('कार (Car)'));

      final outMap = req.toMap();
      expect(outMap['origin_city'], equals('Pune'));
      expect(outMap['destination_city'], equals('Mumbai'));
      expect(outMap['seats_needed'], equals(2));
      expect(outMap['preferred_vehicle'], equals('car'));
      expect(outMap['status'], equals('open'));
    });

    test('routeDisplay formats without sub-areas cleanly', () {
      final req = PassengerRequest(
        id: 'pr-102',
        requesterId: 'user-xyz',
        originCity: 'Delhi',
        destinationCity: 'Jaipur',
        travelDate: DateTime(2026, 11, 21),
        seatsNeeded: 1,
        preferredVehicle: 'any',
        status: 'open',
        createdAt: DateTime.now(),
      );

      expect(req.routeDisplay, equals('Delhi ➔ Jaipur'));
      expect(req.vehicleLabel, equals('Any Vehicle'));
      expect(req.localizedVehicleLabel(isHindi: true), equals('कोई भी वाहन (Any Vehicle)'));
    });

    test('vehicleLabel resolves bike preference correctly', () {
      final req = PassengerRequest(
        id: 'pr-103',
        requesterId: 'user-bike',
        originCity: 'Bengaluru',
        destinationCity: 'Mysuru',
        travelDate: DateTime(2026, 11, 22),
        seatsNeeded: 1,
        preferredVehicle: 'bike',
        status: 'open',
        createdAt: DateTime.now(),
      );

      expect(req.vehicleLabel, equals('Bike'));
      expect(req.localizedVehicleLabel(isHindi: true), equals('बाइक (Bike)'));
    });
  });
}
