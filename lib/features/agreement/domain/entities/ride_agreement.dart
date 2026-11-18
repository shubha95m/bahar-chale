class RideAgreement {
  final String id;
  final String rideRequestId;
  final String pickupDetails;
  final String dropDetails;
  final DateTime agreedDate;
  final String? agreedTime;
  final double? agreedContribution;
  final bool ownerConfirmed;
  final bool requesterConfirmed;
  final String status; // 'draft' | 'confirmed' | 'cancelled' | 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;

  // Rich Participant & Certificate Metadata
  final String? driverName;
  final String? driverId;
  final String? passengerName;
  final String? passengerId;
  final String? vehicleType;
  final int? seatsRequested;
  final String? originCity;
  final String? destinationCity;

  const RideAgreement({
    required this.id,
    required this.rideRequestId,
    required this.pickupDetails,
    required this.dropDetails,
    required this.agreedDate,
    this.agreedTime,
    this.agreedContribution,
    this.ownerConfirmed = false,
    this.requesterConfirmed = false,
    this.status = 'draft',
    required this.createdAt,
    required this.updatedAt,
    this.driverName,
    this.driverId,
    this.passengerName,
    this.passengerId,
    this.vehicleType,
    this.seatsRequested,
    this.originCity,
    this.destinationCity,
  });

  bool get isFullyConfirmed => ownerConfirmed && requesterConfirmed;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ride_request_id': rideRequestId,
      'pickup_details': pickupDetails,
      'drop_details': dropDetails,
      'agreed_date': agreedDate.toIso8601String().split('T').first,
      'agreed_time': agreedTime,
      'agreed_contribution': agreedContribution,
      'owner_confirmed': ownerConfirmed,
      'requester_confirmed': requesterConfirmed,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'driver_name': driverName,
      'driver_id': driverId,
      'passenger_name': passengerName,
      'passenger_id': passengerId,
      'vehicle_type': vehicleType,
      'seats_requested': seatsRequested,
      'origin_city': originCity,
      'destination_city': destinationCity,
    };
  }

  factory RideAgreement.fromMap(Map<String, dynamic> map) {
    return RideAgreement(
      id: map['id'] as String,
      rideRequestId: map['ride_request_id'] as String,
      pickupDetails: map['pickup_details'] as String? ?? '',
      dropDetails: map['drop_details'] as String? ?? '',
      agreedDate: DateTime.tryParse(map['agreed_date']?.toString() ?? '') ?? DateTime.now(),
      agreedTime: map['agreed_time'] as String?,
      agreedContribution: (map['agreed_contribution'] as num?)?.toDouble(),
      ownerConfirmed: map['owner_confirmed'] as bool? ?? false,
      requesterConfirmed: map['requester_confirmed'] as bool? ?? false,
      status: map['status'] as String? ?? 'draft',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
      driverName: map['driver_name'] as String?,
      driverId: map['driver_id'] as String?,
      passengerName: map['passenger_name'] as String?,
      passengerId: map['passenger_id'] as String?,
      vehicleType: map['vehicle_type'] as String?,
      seatsRequested: map['seats_requested'] as int?,
      originCity: map['origin_city'] as String?,
      destinationCity: map['destination_city'] as String?,
    );
  }
}
