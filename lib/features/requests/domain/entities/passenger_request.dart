class PassengerRequest {
  final String id;
  final String requesterId;
  final String originCity;
  final String? originArea;
  final double? originLatitude;
  final double? originLongitude;
  final String destinationCity;
  final String? destinationArea;
  final double? destinationLatitude;
  final double? destinationLongitude;
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
    this.originLatitude,
    this.originLongitude,
    required this.destinationCity,
    this.destinationArea,
    this.destinationLatitude,
    this.destinationLongitude,
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

  String localizedVehicleLabel({bool isHindi = false}) {
    switch (preferredVehicle) {
      case 'car':
        return isHindi ? 'कार (Car)' : 'Car';
      case 'bike':
        return isHindi ? 'बाइक (Bike)' : 'Bike';
      default:
        return isHindi ? 'कोई भी वाहन (Any Vehicle)' : 'Any Vehicle';
    }
  }

  String get vehicleLabel => localizedVehicleLabel(isHindi: false);

  factory PassengerRequest.fromMap(Map<String, dynamic> map) {
    final profiles = map['profiles'] as Map<String, dynamic>?;

    return PassengerRequest(
      id: map['id'] as String,
      requesterId: map['requester_id'] as String,
      originCity: map['origin_city'] as String? ?? '',
      originArea: map['origin_area'] as String?,
      originLatitude: map['origin_latitude'] != null ? (map['origin_latitude'] as num).toDouble() : null,
      originLongitude: map['origin_longitude'] != null ? (map['origin_longitude'] as num).toDouble() : null,
      destinationCity: map['destination_city'] as String? ?? '',
      destinationArea: map['destination_area'] as String?,
      destinationLatitude: map['destination_latitude'] != null ? (map['destination_latitude'] as num).toDouble() : null,
      destinationLongitude: map['destination_longitude'] != null ? (map['destination_longitude'] as num).toDouble() : null,
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
      'origin_latitude': originLatitude,
      'origin_longitude': originLongitude,
      'destination_city': destinationCity.trim(),
      'destination_area': destinationArea?.trim(),
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
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
