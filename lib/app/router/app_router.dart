import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../configuration/supabase_config.dart';
import '../../features/agreement/presentation/pages/agreement_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/conversations_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/requests/presentation/pages/create_passenger_request_page.dart';
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

CustomTransitionPage<void> _buildFadePage({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 180),
  );
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
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '/create-ride',
        name: 'create-ride',
        pageBuilder: (context, state) => _buildFadePage(
          key: state.pageKey,
          child: const CreateRidePage(),
        ),
      ),
      GoRoute(
        path: '/create-passenger-request',
        name: 'create-passenger-request',
        pageBuilder: (context, state) => _buildFadePage(
          key: state.pageKey,
          child: const CreatePassengerRequestPage(),
        ),
      ),
      GoRoute(
        path: '/search-rides',
        name: 'search-rides',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const SearchRidesPage(),
        ),
      ),
      GoRoute(
        path: '/ride/:id',
        name: 'ride-details',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildFadePage(
            key: state.pageKey,
            child: RideDetailsPage(rideId: id),
          );
        },
      ),
      GoRoute(
        path: '/my-travel',
        name: 'my-travel',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyTravelPage(),
        ),
      ),
      GoRoute(
        path: '/agreement/:id',
        name: 'agreement',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildFadePage(
            key: state.pageKey,
            child: AgreementPage(requestId: id),
          );
        },
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildFadePage(
            key: state.pageKey,
            child: ChatPage(requestId: id),
          );
        },
      ),
      GoRoute(
        path: '/conversations',
        name: 'conversations',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ConversationsPage(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProfilePage(),
        ),
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
