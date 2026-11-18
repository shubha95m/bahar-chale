import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/repositories/rides_repository.dart';
import '../../domain/entities/ride.dart';

final ridesRepositoryProvider = Provider<RidesRepository>((ref) {
  return RidesRepository();
});

class SearchParams {
  final String originCity;
  final String destinationCity;
  final DateTime travelDate;
  final String? rideCategory;

  const SearchParams({
    required this.originCity,
    required this.destinationCity,
    required this.travelDate,
    this.rideCategory,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          originCity.trim().toLowerCase() == other.originCity.trim().toLowerCase() &&
          destinationCity.trim().toLowerCase() == other.destinationCity.trim().toLowerCase() &&
          travelDate.year == other.travelDate.year &&
          travelDate.month == other.travelDate.month &&
          travelDate.day == other.travelDate.day &&
          rideCategory == other.rideCategory;

  @override
  int get hashCode =>
      originCity.trim().toLowerCase().hashCode ^
      destinationCity.trim().toLowerCase().hashCode ^
      travelDate.year.hashCode ^
      travelDate.month.hashCode ^
      travelDate.day.hashCode ^
      rideCategory.hashCode;
}

final searchRidesProvider = FutureProvider.family<List<Ride>, SearchParams>((ref, params) async {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(ridesRepositoryProvider);
  return repo.searchRides(
    originCity: params.originCity,
    destinationCity: params.destinationCity,
    travelDate: params.travelDate,
    rideCategory: params.rideCategory,
    excludeUserId: user?.id,
  );
});

class BrowseRidesFilter {
  final String? query;
  final String? vehicleType;

  const BrowseRidesFilter({this.query, this.vehicleType});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowseRidesFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          vehicleType == other.vehicleType;

  @override
  int get hashCode => (query ?? '').hashCode ^ (vehicleType ?? '').hashCode;
}

final allAvailableRidesProvider = FutureProvider.family<List<Ride>, BrowseRidesFilter>((ref, filter) async {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(ridesRepositoryProvider);
  return repo.getAllAvailableRides(
    queryText: filter.query,
    vehicleType: filter.vehicleType,
    excludeUserId: user?.id,
  );
});

final myRidesProvider = FutureProvider.family<List<Ride>, String>((ref, userId) async {
  final repo = ref.watch(ridesRepositoryProvider);
  return repo.getMyRides(userId);
});

final rideDetailsProvider = StreamProvider.family<Ride?, String>((ref, rideId) {
  final repo = ref.watch(ridesRepositoryProvider);
  return repo.streamRideDetails(rideId);
});

class CreateRideNotifier extends StateNotifier<AsyncValue<Ride?>> {
  final RidesRepository _repository;

  CreateRideNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<Ride?> submitRide(Ride ride) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repository.createRide(ride);
      state = AsyncValue.data(created);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final createRideNotifierProvider = StateNotifierProvider<CreateRideNotifier, AsyncValue<Ride?>>((ref) {
  final repo = ref.watch(ridesRepositoryProvider);
  return CreateRideNotifier(repo);
});
