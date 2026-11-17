import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/rides/presentation/pages/create_ride_page.dart';
import '../../features/rides/presentation/pages/my_travel_page.dart';
import '../../features/rides/presentation/pages/ride_details_page.dart';
import '../../features/rides/presentation/pages/search_rides_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/create-ride',
        name: 'create-ride',
        builder: (context, state) => const CreateRidePage(),
      ),
      GoRoute(
        path: '/search-rides',
        name: 'search-rides',
        builder: (context, state) => const SearchRidesPage(),
      ),
      GoRoute(
        path: '/ride/:id',
        name: 'ride-details',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RideDetailsPage(rideId: id);
        },
      ),
      GoRoute(
        path: '/my-travel',
        name: 'my-travel',
        builder: (context, state) => const MyTravelPage(),
      ),
    ],
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      final isLoggedIn = user != null;

      if (!isLoggedIn && !loggingIn) {
        return '/login';
      }
      if (isLoggedIn && loggingIn) {
        return '/';
      }
      return null;
    },
  );
});
