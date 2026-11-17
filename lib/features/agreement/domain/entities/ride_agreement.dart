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
    };
  }

  factory RideAgreement.fromMap(Map<String, dynamic> map) {
    return RideAgreement(
      id: map['id'] as String,
      rideRequestId: map['ride_request_id'] as String,
      pickupDetails: map['pickup_details'] as String,
      dropDetails: map['drop_details'] as String,
      agreedDate: DateTime.parse(map['agreed_date'] as String),
      agreedTime: map['agreed_time'] as String?,
      agreedContribution: (map['agreed_contribution'] as num?)?.toDouble(),
      ownerConfirmed: map['owner_confirmed'] as bool? ?? false,
      requesterConfirmed: map['requester_confirmed'] as bool? ?? false,
      status: map['status'] as String? ?? 'draft',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
