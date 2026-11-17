import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).valueOrNull;
  return authState?.session?.user ?? SupabaseConfig.client.auth.currentUser;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      if (kIsWeb) {
        // Web Google OAuth via Supabase PKCE
        await SupabaseConfig.client.auth.signInWithOAuth(
          OAuthProvider.google,
        );
      } else {
        // Native Mobile Flow with Automatic Browser OAuth Fallback
        bool nativeSuccess = false;
        try {
          final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
          final googleSignIn = GoogleSignIn(
            serverClientId: (webClientId != null && webClientId.isNotEmpty) ? webClientId : null,
            scopes: ['email', 'profile'],
          );

          final googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            // User dismissed dialog
            state = const AsyncValue.data(null);
            return;
          }

          final googleAuth = await googleUser.authentication;
          final idToken = googleAuth.idToken;
          final accessToken = googleAuth.accessToken;

          if (idToken != null) {
            await SupabaseConfig.client.auth.signInWithIdToken(
              provider: OAuthProvider.google,
              idToken: idToken,
              accessToken: accessToken,
            );
            nativeSuccess = true;
          }
        } catch (nativeError) {
          debugPrint('Native Google Sign-In not ready ($nativeError). Falling back to OAuth...');
        }

        if (!nativeSuccess) {
          // Deep link callback on Android
          await SupabaseConfig.client.auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: 'io.supabase.baharchale://login-callback',
            authScreenLaunchMode: LaunchMode.externalApplication,
          );
        }
      }
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      if (e.message.contains('provider is not enabled') || e.code == 'validation_failed') {
        state = AsyncValue.error(
          'Supabase में Google Sign-In अभी चालू नहीं है। डैशबोर्ड (Auth > Providers > Google) में Client ID जोड़ें, या नीचे दिए गए डेमो मोड से जारी रखें।',
          StackTrace.current,
        );
      } else {
        state = AsyncValue.error(e.message, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInAsDemoUser({bool asDriver = true}) async {
    state = const AsyncValue.loading();
    try {
      final email = asDriver ? 'demo@baharchale.local' : 'rider@baharchale.local';
      await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: 'demo123456',
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      if (!kIsWeb) {
        final googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }
      await SupabaseConfig.client.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});
