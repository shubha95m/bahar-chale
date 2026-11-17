import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/requests/domain/entities/ride_request.dart';

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
}
