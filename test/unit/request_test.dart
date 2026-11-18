import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/requests/domain/entities/ride_request.dart';
import 'package:bahar_chale/features/requests/domain/entities/passenger_request.dart';

void main() {
  group('RideRequest Model', () {
    test('RideRequest serialization and parsing with profile join data', () {
      final map = {
        'id': 'req-uuid-1',
        'ride_id': 'ride-uuid-1',
        'requester_id': 'user-456',
        'seats_requested': 2,
        'status': 'pending',
        'message': 'सामान के साथ 2 लोग हैं',
        'created_at': '2026-11-17T12:00:00Z',
        'updated_at': '2026-11-17T12:00:00Z',
        'profiles': {
          'display_name': 'अमित कुमार',
          'avatar_url': 'https://example.com/avatar.jpg',
          'home_city': 'Pune',
        },
      };

      final request = RideRequest.fromMap(map);

      expect(request.id, 'req-uuid-1');
      expect(request.seatsRequested, 2);
      expect(request.requesterName, 'अमित कुमार');
      expect(request.requesterCity, 'Pune');
      expect(request.status, 'pending');

      final serialized = request.toMap();
      expect(serialized['ride_id'], 'ride-uuid-1');
      expect(serialized['seats_requested'], 2);
    });
  });

  group('PassengerRequest Model', () {
    test('PassengerRequest serializes and parses coordinates and areas correctly', () {
      final map = {
        'id': 'pass-uuid-101',
        'requester_id': 'user-789',
        'origin_city': 'Suratpura',
        'origin_area': 'Samariya Khurd, Begun Tehsil',
        'origin_latitude': 25.1052788,
        'origin_longitude': 75.0884306,
        'destination_city': 'Begun',
        'destination_area': 'Begun Tehsil',
        'destination_latitude': 24.9860286,
        'destination_longitude': 75.0132209,
        'travel_date': '2026-11-25',
        'travel_time': '10:30',
        'is_time_flexible': true,
        'seats_needed': 2,
        'preferred_vehicle': 'car',
        'status': 'open',
        'created_at': '2026-11-18T10:00:00Z',
        'profiles': {
          'display_name': 'पूजा शर्मा',
          'avatar_url': null,
        },
      };

      final req = PassengerRequest.fromMap(map);

      expect(req.id, 'pass-uuid-101');
      expect(req.originCity, 'Suratpura');
      expect(req.originArea, 'Samariya Khurd, Begun Tehsil');
      expect(req.originLatitude, 25.1052788);
      expect(req.originLongitude, 75.0884306);
      expect(req.destinationCity, 'Begun');
      expect(req.destinationLatitude, 24.9860286);
      expect(req.destinationLongitude, 75.0132209);
      expect(req.requesterName, 'पूजा शर्मा');
      expect(req.routeDisplay, 'Suratpura (Samariya Khurd, Begun Tehsil) ➔ Begun (Begun Tehsil)');

      final serialized = req.toMap();
      expect(serialized['origin_latitude'], 25.1052788);
      expect(serialized['destination_longitude'], 75.0132209);
    });
  });
}
