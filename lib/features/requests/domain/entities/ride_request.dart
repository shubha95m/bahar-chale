class RideRequest {
  final String id;
  final String rideId;
  final String requesterId;
  final int seatsRequested;
  final String status; // 'pending' | 'accepted' | 'rejected' | 'cancelled'
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? requesterName;
  final String? requesterAvatar;
  final String? requesterCity;
  final bool isRequesterVerified;
  final String? requesterIdType;
  final String? requesterIdMasked;

  const RideRequest({
    required this.id,
    required this.rideId,
    required this.requesterId,
    this.seatsRequested = 1,
    this.status = 'pending',
    this.message,
    required this.createdAt,
    required this.updatedAt,
    this.requesterName,
    this.requesterAvatar,
    this.requesterCity,
    this.isRequesterVerified = false,
    this.requesterIdType,
    this.requesterIdMasked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ride_id': rideId,
      'requester_id': requesterId,
      'seats_requested': seatsRequested,
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RideRequest.fromMap(Map<String, dynamic> map, {String? requesterName, String? requesterAvatar, String? requesterCity}) {
    final profiles = map['profiles'] as Map<String, dynamic>?;
    return RideRequest(
      id: map['id'] as String,
      rideId: map['ride_id'] as String,
      requesterId: map['requester_id'] as String,
      seatsRequested: map['seats_requested'] as int? ?? 1,
      status: map['status'] as String? ?? 'pending',
      message: map['message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      requesterName: requesterName ?? profiles?['display_name'] as String?,
      requesterAvatar: requesterAvatar ?? profiles?['avatar_url'] as String?,
      requesterCity: requesterCity ?? profiles?['home_city'] as String?,
      isRequesterVerified: profiles?['id_verified'] as bool? ?? false,
      requesterIdType: profiles?['id_type'] as String?,
      requesterIdMasked: profiles?['id_number_masked'] as String?,
    );
  }
}
