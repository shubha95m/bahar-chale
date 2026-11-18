class PassengerRequest {
  final String id;
  final String requesterId;
  final String originCity;
  final String? originArea;
  final String destinationCity;
  final String? destinationArea;
  final DateTime travelDate;
  final String? travelTime;
  final bool isTimeFlexible;
  final int seatsNeeded;
  final String preferredVehicle; // 'any' | 'car' | 'bike'
  final double? contributionBudget;
  final String? notes;
  final String status; // 'open' | 'matched' | 'cancelled' | 'completed'
  final DateTime createdAt;
  final String? requesterName;
  final String? requesterAvatar;

  const PassengerRequest({
    required this.id,
    required this.requesterId,
    required this.originCity,
    this.originArea,
    required this.destinationCity,
    this.destinationArea,
    required this.travelDate,
    this.travelTime,
    this.isTimeFlexible = true,
    this.seatsNeeded = 1,
    this.preferredVehicle = 'any',
    this.contributionBudget,
    this.notes,
    this.status = 'open',
    required this.createdAt,
    this.requesterName,
    this.requesterAvatar,
  });

  String get routeDisplay {
    final from = originArea != null && originArea!.isNotEmpty
        ? '$originCity ($originArea)'
        : originCity;
    final to = destinationArea != null && destinationArea!.isNotEmpty
        ? '$destinationCity ($destinationArea)'
        : destinationCity;
    return '$from ➔ $to';
  }

  String get vehicleLabel {
    switch (preferredVehicle) {
      case 'car':
        return 'कार (Car)';
      case 'bike':
        return 'बाइक (Bike)';
      default:
        return 'कोई भी वाहन (Any Vehicle)';
    }
  }

  factory PassengerRequest.fromMap(Map<String, dynamic> map) {
    final profiles = map['profiles'] as Map<String, dynamic>?;

    return PassengerRequest(
      id: map['id'] as String,
      requesterId: map['requester_id'] as String,
      originCity: map['origin_city'] as String? ?? '',
      originArea: map['origin_area'] as String?,
      destinationCity: map['destination_city'] as String? ?? '',
      destinationArea: map['destination_area'] as String?,
      travelDate: DateTime.tryParse(map['travel_date']?.toString() ?? '') ?? DateTime.now(),
      travelTime: map['travel_time'] as String?,
      isTimeFlexible: map['is_time_flexible'] as bool? ?? true,
      seatsNeeded: map['seats_needed'] as int? ?? 1,
      preferredVehicle: map['preferred_vehicle'] as String? ?? 'any',
      contributionBudget: map['contribution_budget'] != null
          ? double.tryParse(map['contribution_budget'].toString())
          : null,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'open',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      requesterName: profiles?['display_name'] as String?,
      requesterAvatar: profiles?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requester_id': requesterId,
      'origin_city': originCity.trim(),
      'origin_area': originArea?.trim(),
      'destination_city': destinationCity.trim(),
      'destination_area': destinationArea?.trim(),
      'travel_date': travelDate.toIso8601String().split('T').first,
      'travel_time': travelTime,
      'is_time_flexible': isTimeFlexible,
      'seats_needed': seatsNeeded,
      'preferred_vehicle': preferredVehicle,
      'contribution_budget': contributionBudget,
      'notes': notes?.trim(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
