class Ride {
  final String id;
  final String ownerId;
  final String rideCategory; // 'private_vehicle' | 'general_travel'
  final String? vehicleType; // 'car' | 'bike' | 'other'
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
  final int totalSeats;
  final int availableSeats;
  final double? contributionAmount;
  final String? notes;
  final String status; // 'draft' | 'open' | 'full' | 'cancelled' | 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerName;
  final String? ownerAvatar;

  const Ride({
    required this.id,
    required this.ownerId,
    required this.rideCategory,
    this.vehicleType,
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
    this.totalSeats = 1,
    this.availableSeats = 1,
    this.contributionAmount,
    this.notes,
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
    this.ownerName,
    this.ownerAvatar,
  });

  String get routeDisplay {
    final from = originArea != null && originArea!.isNotEmpty
        ? '$originCity ($originArea)'
        : originCity;
    final to = destinationArea != null && destinationArea!.isNotEmpty
        ? '$destinationCity ($destinationArea)'
        : destinationCity;
    return '$from → $to';
  }

  String localizedVehicleLabel({bool isHindi = false}) {
    if (rideCategory == 'general_travel') {
      return isHindi ? 'सामान्य यात्रा समन्वय (General Travel)' : 'General Travel Coordination';
    }
    switch (vehicleType) {
      case 'bike':
        return isHindi ? '🏍️ बाइक (Bike)' : '🏍️ Bike';
      case 'car':
        return isHindi ? '🚗 कार (Car)' : '🚗 Car';
      default:
        return isHindi ? '🛺 अन्य / साझा (Other)' : '🛺 Other / Shared';
    }
  }

  String get vehicleLabel => localizedVehicleLabel(isHindi: false);

  String get vehicleIcon {
    if (rideCategory == 'general_travel') return '🎒';
    switch (vehicleType) {
      case 'bike':
        return '🏍️';
      case 'car':
        return '🚗';
      default:
        return '🛺';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'ride_category': rideCategory,
      'vehicle_type': vehicleType,
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
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'contribution_amount': contributionAmount,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Ride.fromMap(Map<String, dynamic> map, {String? ownerName, String? ownerAvatar}) {
    return Ride(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      rideCategory: map['ride_category'] as String,
      vehicleType: map['vehicle_type'] as String?,
      originCity: map['origin_city'] as String,
      originArea: map['origin_area'] as String?,
      originLatitude: (map['origin_latitude'] as num?)?.toDouble(),
      originLongitude: (map['origin_longitude'] as num?)?.toDouble(),
      destinationCity: map['destination_city'] as String,
      destinationArea: map['destination_area'] as String?,
      destinationLatitude: (map['destination_latitude'] as num?)?.toDouble(),
      destinationLongitude: (map['destination_longitude'] as num?)?.toDouble(),
      travelDate: DateTime.parse(map['travel_date'] as String),
      travelTime: map['travel_time'] as String?,
      isTimeFlexible: map['is_time_flexible'] as bool? ?? true,
      totalSeats: map['total_seats'] as int? ?? 1,
      availableSeats: map['available_seats'] as int? ?? 1,
      contributionAmount: (map['contribution_amount'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'open',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      ownerName: ownerName ?? (map['profiles'] as Map<String, dynamic>?)?['display_name'] as String?,
      ownerAvatar: ownerAvatar ?? (map['profiles'] as Map<String, dynamic>?)?['avatar_url'] as String?,
    );
  }
}
