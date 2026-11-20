/// Manages temporary state during user onboarding/registration
class AuthRegistrationState {
  /// When true, prevents GoRouter redirect from kicking the user out of the
  /// onboarding flow while they are uploading their profile photo & ID.
  static bool isCompletingVerification = false;
}
