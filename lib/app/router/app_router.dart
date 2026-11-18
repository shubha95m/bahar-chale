import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../configuration/supabase_config.dart';
import '../../features/agreement/presentation/pages/agreement_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/rides/presentation/pages/create_ride_page.dart';
import '../../features/rides/presentation/pages/my_travel_page.dart';
import '../../features/rides/presentation/pages/ride_details_page.dart';
import '../../features/rides/presentation/pages/search_rides_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshStream = GoRouterRefreshStream(SupabaseConfig.client.auth.onAuthStateChange);
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshStream,
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
      GoRoute(
        path: '/agreement/:id',
        name: 'agreement',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AgreementPage(requestId: id);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChatPage(requestId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    redirect: (context, state) {
      final session = SupabaseConfig.client.auth.currentSession;
      final user = session?.user ?? SupabaseConfig.client.auth.currentUser;
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
