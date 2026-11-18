import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
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
      // Pre-check if Google provider is enabled on Supabase backend before redirecting
      try {
        final settingsUri = Uri.parse('${SupabaseConfig.defaultUrl}/auth/v1/settings');
        final settingsRes = await http.get(settingsUri, headers: {'apikey': SupabaseConfig.defaultAnonKey});
        if (settingsRes.statusCode == 200) {
          final settingsData = jsonDecode(settingsRes.body) as Map<String, dynamic>;
          final externalProviders = settingsData['external'] as Map<String, dynamic>?;
          if (externalProviders?['google'] != true) {
            throw const AuthException(
              'Supabase में Google Sign-In Provider अभी सक्रिय नहीं है। कृपया Supabase Dashboard (Auth > Providers > Google) में Client ID जोड़ें, या नीचे दिए गए डेमो मोड (Driver/Rider) से तुरंत प्रवेश करें।',
            );
          }
        }
      } catch (checkErr) {
        if (checkErr is AuthException) rethrow;
      }

      if (kIsWeb) {
        // Web Google OAuth via Supabase PKCE with dynamic origin callback
        final redirectUrl = Uri.base.origin;
        await SupabaseConfig.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectUrl,
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

  static final _disposableDomains = {
    'mailinator.com',
    'tempmail.com',
    '10minutemail.com',
    'guerrillamail.com',
    'sharklasers.com',
    'yopmail.com',
    'trashmail.com',
    'getairmail.com',
    'dispostable.com',
    'throwawaymail.com',
    'fakemailgenerator.com',
    'temp-mail.org',
    'mohmal.com',
    'burnermail.io',
    'inboxkitten.com',
    'crazymailing.com',
  };

  static String _cleanErrorMessage(dynamic e) {
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
        return 'गलत ईमेल या पासवर्ड। कृपया विवरण पुनः जांचें या "नया खाता बनाएं" चुनें।';
      }
      if (msg.contains('email not confirmed')) {
        return 'ईमेल अभी सत्यापित नहीं है। कृपया OTP सत्यापन पूरा करें।';
      }
      if (msg.contains('rate limit') || msg.contains('too many requests')) {
        return 'सुरक्षा सीमा: बहुत अधिक अनुरोध। कृपया कुछ मिनट बाद पुनः प्रयास करें।';
      }
      if (msg.contains('token has expired') || msg.contains('otp expired')) {
        return 'OTP की समय सीमा समाप्त हो गई है। कृपया "OTP पुनः भेजें" पर टैप करें।';
      }
      if (msg.contains('invalid token') || msg.contains('token is invalid')) {
        return 'गलत OTP कोड। कृपया अपने ईमेल पर प्राप्त 6-अंकों का सही कोड दर्ज करें।';
      }
      if (msg.contains('user already registered')) {
        return 'यह ईमेल पहले से पंजीकृत है। कृपया "साइन इन" टैब पर जाकर पासवर्ड से लॉगिन करें।';
      }
      return e.message;
    }
    if (e is FormatException) {
      return e.message;
    }
    return e.toString();
  }

  /// Sends a 6-digit verification OTP to the user's real email
  Future<bool> sendSignupOtp({required String email, required String displayName}) async {
    state = const AsyncValue.loading();
    try {
      final cleanEmail = email.trim().toLowerCase();
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(cleanEmail)) {
        throw const FormatException('कृपया एक वैध और सही ईमेल पता दर्ज करें (उदा. yourname@gmail.com)।');
      }

      final domain = cleanEmail.split('@').last;
      if (_disposableDomains.contains(domain)) {
        throw const FormatException('अस्थाई / डमी ईमेल (Disposable email) मान्य नहीं है। कृपया अपना असली व्यक्तिगत ईमेल उपयोग करें।');
      }

      await SupabaseConfig.client.auth.signInWithOtp(
        email: cleanEmail,
        shouldCreateUser: true,
        data: {'full_name': displayName.trim(), 'name': displayName.trim()},
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(_cleanErrorMessage(e), st);
      return false;
    }
  }

  /// Verifies the 6-digit OTP code received on email
  Future<bool> verifySignupOtp({required String email, required String token}) async {
    state = const AsyncValue.loading();
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanToken = token.trim();

      final res = await SupabaseConfig.client.auth.verifyOTP(
        email: cleanEmail,
        token: cleanToken,
        type: OtpType.email,
      );

      if (res.session == null && res.user == null) {
        throw const AuthException('OTP सत्यापन विफल रहा। कृपया सही 6-अंकों का कोड दर्ज करें।');
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(_cleanErrorMessage(e), st);
      return false;
    }
  }

  /// Sets the user's chosen password and profile name after OTP verification
  Future<bool> completeSignupPassword({required String password, required String displayName}) async {
    state = const AsyncValue.loading();
    try {
      if (password.length < 6) {
        throw const FormatException('पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।');
      }

      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(
          password: password,
          data: {'full_name': displayName.trim(), 'name': displayName.trim()},
        ),
      );

      // Ensure profile record is immediately updated in public.profiles
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        await SupabaseConfig.client.from('profiles').upsert({
          'id': user.id,
          'display_name': displayName.trim(),
          'email': user.email,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(_cleanErrorMessage(e), st);
      return false;
    }
  }

  /// Logs in an existing user with real email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseConfig.client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_cleanErrorMessage(e), st);
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
