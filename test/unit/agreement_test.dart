import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/agreement/domain/entities/ride_agreement.dart';

void main() {
  group('RideAgreement Model & Logic', () {
    test('isFullyConfirmed returns true only when both parties have confirmed', () {
      final pendingAgreement = RideAgreement(
        id: 'agr-1',
        rideRequestId: 'req-1',
        pickupDetails: 'Hinjawadi Phase 1',
        dropDetails: 'Dadar Station',
        agreedDate: DateTime(2026, 11, 20),
        agreedContribution: 350.0,
        ownerConfirmed: true,
        requesterConfirmed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(pendingAgreement.isFullyConfirmed, isFalse);

      final confirmedAgreement = RideAgreement(
        id: 'agr-2',
        rideRequestId: 'req-2',
        pickupDetails: 'Kothrud',
        dropDetails: 'Thane West',
        agreedDate: DateTime(2026, 11, 20),
        agreedContribution: 400.0,
        ownerConfirmed: true,
        requesterConfirmed: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(confirmedAgreement.isFullyConfirmed, isTrue);
    });

    test('RideAgreement serialization round-trip integrity', () {
      final map = {
        'id': 'agr-3',
        'ride_request_id': 'req-3',
        'pickup_details': 'Wakad Chowk',
        'drop_details': 'Vashi Plaza',
        'agreed_date': '2026-11-25',
        'agreed_time': '08:30:00',
        'agreed_contribution': 300.0,
        'owner_confirmed': true,
        'requester_confirmed': true,
        'status': 'confirmed',
        'created_at': '2026-11-17T12:00:00Z',
        'updated_at': '2026-11-17T12:00:00Z',
      };

      final agreement = RideAgreement.fromMap(map);
      expect(agreement.id, 'agr-3');
      expect(agreement.pickupDetails, 'Wakad Chowk');
      expect(agreement.isFullyConfirmed, isTrue);

      final serialized = agreement.toMap();
      expect(serialized['agreed_date'], '2026-11-25');
      expect(serialized['owner_confirmed'], isTrue);
    });

    test('RideAgreement parses rich certificate metadata correctly', () {
      final map = {
        'id': 'agr-cert-1',
        'ride_request_id': 'req-cert-1',
        'pickup_details': 'Samariya Khurd, Begun Tehsil',
        'drop_details': 'Begun Tehsil',
        'agreed_date': '2026-11-25',
        'agreed_time': '09:00',
        'agreed_contribution': 50.0,
        'owner_confirmed': true,
        'requester_confirmed': true,
        'status': 'confirmed',
        'created_at': '2026-11-18T10:00:00Z',
        'updated_at': '2026-11-18T10:05:00Z',
        'driver_name': 'सुरेश पाटीदार',
        'driver_id': 'driver-123',
        'passenger_name': 'पूजा शर्मा',
        'passenger_id': 'passenger-456',
        'vehicle_type': 'car',
        'seats_requested': 2,
        'origin_city': 'Suratpura',
        'destination_city': 'Begun',
      };

      final agreement = RideAgreement.fromMap(map);
      expect(agreement.driverName, 'सुरेश पाटीदार');
      expect(agreement.passengerName, 'पूजा शर्मा');
      expect(agreement.vehicleType, 'car');
      expect(agreement.seatsRequested, 2);
      expect(agreement.originCity, 'Suratpura');
      expect(agreement.destinationCity, 'Begun');
      expect(agreement.isFullyConfirmed, isTrue);

      final serialized = agreement.toMap();
      expect(serialized['driver_name'], 'सुरेश पाटीदार');
      expect(serialized['passenger_id'], 'passenger-456');
    });
  });
}
