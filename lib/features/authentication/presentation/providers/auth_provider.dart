import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../../../core/localization/app_language.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).valueOrNull;
  return authState?.session?.user ?? SupabaseConfig.client.auth.currentUser;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref? _ref;
  AuthController([this._ref]) : super(const AsyncValue.data(null));

  bool get isHindi => _ref?.read(appLanguageProvider) == AppLanguage.hindi;

  String? _signupToken;
  String? _verifiedToken;
  String? _signupEmail;

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
            throw AuthException(
              isHindi
                  ? 'Supabase में Google Sign-In Provider अभी सक्रिय नहीं है। कृपया Supabase Dashboard (Auth > Providers > Google) में Client ID जोड़ें, या नीचे दिए गए डेमो मोड (Driver/Rider) से तुरंत प्रवेश करें।'
                  : 'Google Sign-In is not currently enabled in Supabase Dashboard. Please configure Google OAuth credentials or sign in with email.',
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
          final webClientId = dotenv.isInitialized
              ? dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID')
              : const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');
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
          isHindi
              ? 'Supabase में Google Sign-In अभी चालू नहीं है। डैशबोर्ड (Auth > Providers > Google) में Client ID जोड़ें, या नीचे दिए गए डेमो मोड से जारी रखें।'
              : 'Google Sign-In is not currently enabled in Supabase Dashboard. Please configure credentials in Supabase.',
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

  String _cleanErrorMessage(dynamic e) {
    final hindi = isHindi;
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
        return hindi
            ? 'गलत ईमेल या पासवर्ड। कृपया विवरण पुनः जांचें या "नया खाता बनाएं" चुनें।'
            : 'Incorrect email or password. Please verify your credentials or create a new account.';
      }
      if (msg.contains('email not confirmed')) {
        return hindi
            ? 'ईमेल अभी सत्यापित नहीं है। कृपया OTP सत्यापन पूरा करें।'
            : 'Email not verified yet. Please complete OTP verification.';
      }
      if (msg.contains('rate limit') || msg.contains('too many requests')) {
        return hindi
            ? 'सुरक्षा सीमा: बहुत अधिक अनुरोध। कृपया कुछ मिनट बाद पुनः प्रयास करें।'
            : 'Security limit: Too many requests. Please retry after a few minutes.';
      }
      if (msg.contains('token has expired') || msg.contains('otp expired')) {
        return hindi
            ? 'OTP की समय सीमा समाप्त हो गई है। कृपया "OTP पुनः भेजें" पर टैप करें।'
            : 'OTP expired. Please tap "Resend OTP".';
      }
      if (msg.contains('invalid token') || msg.contains('token is invalid')) {
        return hindi
            ? 'गलत OTP कोड। कृपया अपने ईमेल पर प्राप्त 6-अंकों का सही कोड दर्ज करें।'
            : 'Incorrect OTP code. Please enter the valid 6-digit code received on your email.';
      }
      if (msg.contains('user already registered')) {
        return hindi
            ? 'यह ईमेल पहले से पंजीकृत है। कृपया "साइन इन" टैब पर जाकर पासवर्ड से लॉगिन करें।'
            : 'This email is already registered. Please go to the "Sign In" tab to log in.';
      }
      return e.message;
    }
    if (e is FormatException) {
      return e.message;
    }
    return e.toString();
  }

  /// Sends a 6-digit verification OTP to the user's real email via secure Edge Service (Gmail SMTP)
  Future<bool> sendSignupOtp({required String email, required String displayName}) async {
    state = const AsyncValue.loading();
    try {
      final cleanEmail = email.trim().toLowerCase();
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(cleanEmail)) {
        throw FormatException(
          isHindi
              ? 'कृपया एक वैध और सही ईमेल पता दर्ज करें (उदा. yourname@gmail.com)।'
              : 'Please enter a valid email address (e.g. yourname@gmail.com).',
        );
      }

      final domain = cleanEmail.split('@').last;
      if (_disposableDomains.contains(domain)) {
        throw FormatException(
          isHindi
              ? 'अस्थाई / डमी ईमेल (Disposable email) मान्य नहीं है। कृपया अपना असली व्यक्तिगत ईमेल उपयोग करें।'
              : 'Disposable or dummy email is not permitted. Please use your real personal email.',
        );
      }

      final uri = Uri.parse('${SupabaseConfig.defaultUrl}/functions/v1/custom-auth');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.defaultAnonKey,
        },
        body: jsonEncode({
          'action': 'send-otp',
          'email': cleanEmail,
          'name': displayName.trim(),
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        _signupToken = data['token'] as String?;
        _signupEmail = cleanEmail;
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw FormatException(data['error']?.toString() ?? (isHindi ? 'OTP भेजने में त्रुटि हुई।' : 'Error sending OTP.'));
      }
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

      if (cleanToken.length < 6) {
        throw FormatException(isHindi ? 'कृपया 6-अंकों का OTP कोड दर्ज करें।' : 'Please enter the 6-digit OTP code.');
      }

      final uri = Uri.parse('${SupabaseConfig.defaultUrl}/functions/v1/custom-auth');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.defaultAnonKey,
        },
        body: jsonEncode({
          'action': 'verify-otp',
          'email': cleanEmail,
          'otp': cleanToken,
          'token': _signupToken,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        _verifiedToken = data['verifiedToken'] as String?;
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw FormatException(data['error']?.toString() ?? (isHindi ? 'गलत OTP कोड। कृपया सही 6-अंकों का कोड दर्ज करें।' : 'Invalid OTP code. Please enter the correct 6-digit code.'));
      }
    } catch (e, st) {
      state = AsyncValue.error(_cleanErrorMessage(e), st);
      return false;
    }
  }

  /// Sets the user's chosen password and profile name after OTP verification and records legal consent
  Future<bool> completeSignupPassword({
    required String password,
    required String displayName,
    bool termsAccepted = true,
    String termsVersion = 'v1.0-2026',
    String? termsConsentText,
  }) async {
    state = const AsyncValue.loading();
    try {
      if (!termsAccepted) {
        throw FormatException(isHindi ? 'कृपया आगे बढ़ने के लिए नियम व शर्तें और कानूनी सहमति स्वीकार करें।' : 'Please accept Terms & Conditions and legal consent to proceed.');
      }

      if (password.length < 6) {
        throw FormatException(isHindi ? 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।' : 'Password must be at least 6 characters.');
      }

      final email = _signupEmail ?? SupabaseConfig.client.auth.currentUser?.email ?? '';
      if (email.isEmpty) {
        throw FormatException(isHindi ? 'सत्यापन सत्र समाप्त हो गया। कृपया पुनः OTP भेजें।' : 'Verification session expired. Please resend OTP.');
      }

      final consentStatement = termsConsentText ??
          'I accept the Bahar Chale Terms of Service, Privacy Policy, and Community Ride Coordination Guidelines under IT Act 2000 & DPDP Act 2023.';

      final uri = Uri.parse('${SupabaseConfig.defaultUrl}/functions/v1/custom-auth');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.defaultAnonKey,
        },
        body: jsonEncode({
          'action': 'complete-signup',
          'email': email,
          'password': password,
          'name': displayName.trim(),
          'verifiedToken': _verifiedToken,
          'termsAccepted': true,
          'termsVersion': termsVersion,
          'termsConsentText': consentStatement,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        // Officially establish Supabase auth session
        await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        state = const AsyncValue.data(null);
        return true;
      } else {
        throw FormatException(data['error']?.toString() ?? (isHindi ? 'पंजीकरण विफल रहा। कृपया पुनः प्रयास करें।' : 'Registration failed. Please try again.'));
      }
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
  return AuthController(ref);
});
