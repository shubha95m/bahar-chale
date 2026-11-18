import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/terms_and_conditions_dialog.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Tab: 0 = Sign In (Email+Password), 1 = Sign Up with OTP
  int _selectedTab = 0;

  // Controllers for Sign In
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  // Controllers & State for Sign Up with OTP
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupOtpController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  bool _obscureSignupPassword = true;

  // 1 = Enter Name & Email, 2 = Enter OTP, 3 = Create Password
  int _signupStep = 1;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupOtpController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;
    AppSnackBar.show(context, message: message, isError: isError, isSuccess: isSuccess);
  }

  // --- Sign In Handler ---
  Future<void> _handleSignIn() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('कृपया ईमेल और पासवर्ड दोनों दर्ज करें।', isError: true);
      return;
    }

    await ref.read(authControllerProvider.notifier).signInWithEmail(email, password);
  }

  // --- Sign Up Step 1: Send OTP ---
  Future<void> _handleSendOtp() async {
    final name = _signupNameController.text.trim();
    final email = _signupEmailController.text.trim();

    if (name.isEmpty) {
      _showSnack('कृपया अपना पूरा नाम दर्ज करें।', isError: true);
      return;
    }
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _showSnack('कृपया एक असली और वैध ईमेल पता दर्ज करें।', isError: true);
      return;
    }

    final sent = await ref.read(authControllerProvider.notifier).sendSignupOtp(
      email: email,
      displayName: name,
    );

    if (sent && mounted) {
      setState(() => _signupStep = 2);
      _showSnack('6-अंकों का OTP कोड आपके ईमेल ($email) पर भेजा गया है!', isSuccess: true);
    }
  }

  // --- Sign Up Step 2: Verify OTP ---
  Future<void> _handleVerifyOtp() async {
    final email = _signupEmailController.text.trim();
    final otp = _signupOtpController.text.trim();

    if (otp.length < 6) {
      _showSnack('कृपया ईमेल पर आया 6-अंकों का OTP कोड दर्ज करें।', isError: true);
      return;
    }

    final verified = await ref.read(authControllerProvider.notifier).verifySignupOtp(
      email: email,
      token: otp,
    );

    if (verified && mounted) {
      setState(() => _signupStep = 3);
      _showSnack('ईमेल सफलतापूर्वक सत्यापित हुआ! अब अपना पासवर्ड बनाएं।', isSuccess: true);
    }
  }

  // --- Sign Up Step 3: Set Password & Finish ---
  Future<void> _handleCompleteSignup() async {
    final name = _signupNameController.text.trim();
    final password = _signupPasswordController.text;
    final confirmPassword = _signupConfirmPasswordController.text;

    if (!_acceptedTerms) {
      _showSnack(
        ref.read(stringsProvider).isHindi
            ? 'कृपया आगे बढ़ने के लिए नियम व शर्तें स्वीकार करें।'
            : 'Please accept Terms & Conditions to proceed.',
        isError: true,
      );
      return;
    }

    if (password.length < 6) {
      _showSnack('पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।', isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showSnack('दोनों पासवर्ड मेल नहीं खाते। कृपया पुनः जांचें।', isError: true);
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).completeSignupPassword(
      password: password,
      displayName: name,
      termsAccepted: _acceptedTerms,
      termsVersion: 'v1.0-2026',
      termsConsentText: 'I accept the Bahar Chale Terms of Service, Privacy Policy, and Community Ride Coordination Guidelines under IT Act 2000 & DPDP Act 2023.',
    );

    if (success && mounted) {
      _showSnack('पंजीकरण सफल! आपका स्वागत है।', isSuccess: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          final msg = err.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', '');
          _showSnack(msg, isError: true);
        },
      );
    });

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: bottomInset > 0 ? bottomInset + 30 : 64.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Row: Language Switcher
                      const Align(
                        alignment: Alignment.topRight,
                        child: LanguageSwitcherButton(),
                      ),
                      const SizedBox(height: 6),

                      // App Logo & Branding
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            size: 38,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        s.appTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.appTagline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tabs: Sign In vs Sign Up
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => setState(() => _selectedTab = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _selectedTab == 0
                                        ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                                        : null,
                                  ),
                                  child: Text(
                                    s.signInTab,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: _selectedTab == 0 ? AppTheme.primaryGreen : AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => setState(() => _selectedTab = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _selectedTab == 1
                                        ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                                        : null,
                                  ),
                                  child: Text(
                                    s.signUpTab,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: _selectedTab == 1 ? AppTheme.primaryGreen : AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // TAB 0: Sign In (Email + Password)
                      if (_selectedTab == 0) ...[
                        TextField(
                          controller: _loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: s.isHindi ? 'ईमेल पता (Email) *' : 'Email Address *',
                            hintText: 'your.name@gmail.com',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _loginPasswordController,
                          obscureText: _obscureLoginPassword,
                          decoration: InputDecoration(
                            labelText: s.isHindi ? 'पासवर्ड (Password) *' : 'Password *',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureLoginPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.primaryGreen),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                s.isHindi
                                    ? 'एक बार लॉगिन करने पर अगली बार स्वतः लॉगिन रहेगा'
                                    : 'Stay logged in securely on this device',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(
                                  s.isHindi ? 'साइन इन करें' : 'Sign In',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],

                      // TAB 1: Sign Up with Real Email + OTP Verification
                      if (_selectedTab == 1) ...[
                        // Step 1: Name and Real Email
                        if (_signupStep == 1) ...[
                          TextField(
                            controller: _signupNameController,
                            decoration: InputDecoration(
                              labelText: s.isHindi ? 'आपका पूरा नाम *' : 'Your Full Name *',
                              hintText: s.isHindi ? 'उदा. शुभम शर्मा' : 'e.g. Shubham Sharma',
                              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _signupEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: s.isHindi ? 'असली ईमेल पता (Gmail / Other) *' : 'Real Email Address *',
                              hintText: 'name@gmail.com',
                              prefixIcon: const Icon(Icons.mark_email_read_outlined, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.isHindi
                                ? '🛡️ केवल असली ईमेल मान्य है। सत्यापन हेतु 6-अंकों का OTP भेजा जाएगा।'
                                : '🛡️ Only genuine email accepted. A 6-digit OTP code will be sent.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _handleSendOtp,
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: Text(
                              s.isHindi ? 'ईमेल पर OTP भेजें' : 'Send OTP to Email',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],

                        // Step 2: OTP Verification
                        if (_signupStep == 2) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mail_outline, color: AppTheme.primaryGreen, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.isHindi
                                            ? '${_signupEmailController.text.trim()} पर 6-अंकों का OTP भेजा गया है।'
                                            : 'A 6-digit OTP was sent to ${_signupEmailController.text.trim()}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.isHindi
                                            ? '💡 इनबॉक्स में न मिलने पर स्पैम (Spam / Junk) फ़ोल्डर भी देखें।'
                                            : '💡 If not in Primary, please check your Spam / Junk folder.',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _signupOtpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 6),
                            decoration: InputDecoration(
                              labelText: s.isHindi ? '6-अंकों का OTP दर्ज करें *' : 'Enter 6-digit OTP *',
                              counterText: '',
                              prefixIcon: const Icon(Icons.pin_outlined, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _handleVerifyOtp,
                            icon: const Icon(Icons.verified_outlined, size: 18),
                            label: Text(
                              s.isHindi ? 'OTP सत्यापित करें' : 'Verify OTP',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _signupStep = 1),
                                child: Text(s.isHindi ? 'ईमेल बदलें' : 'Change Email', style: const TextStyle(fontSize: 12)),
                              ),
                              TextButton(
                                onPressed: isLoading ? null : _handleSendOtp,
                                child: Text(s.isHindi ? 'OTP पुनः भेजें' : 'Resend OTP', style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],

                        // Step 3: Password Creation
                        if (_signupStep == 3) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s.isHindi
                                        ? 'ईमेल सत्यापित हुआ! अब सुरक्षित पासवर्ड बनाएं:'
                                        : 'Email verified! Now set a secure password:',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _signupPasswordController,
                            obscureText: _obscureSignupPassword,
                            decoration: InputDecoration(
                              labelText: s.isHindi ? 'नया पासवर्ड बनाएं (कम से कम 6 अक्षर) *' : 'Create Password (min 6 chars) *',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureSignupPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _signupConfirmPasswordController,
                            obscureText: _obscureSignupPassword,
                            decoration: InputDecoration(
                              labelText: s.isHindi ? 'पासवर्ड की पुष्टि करें *' : 'Confirm Password *',
                              prefixIcon: const Icon(Icons.lock_reset, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Legal Terms & Privacy Consent Checkbox
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: _acceptedTerms ? AppTheme.primaryGreen.withOpacity(0.06) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _acceptedTerms ? AppTheme.primaryGreen.withOpacity(0.4) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _acceptedTerms,
                                    activeColor: AppTheme.primaryGreen,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                                    child: Text.rich(
                                      TextSpan(
                                        text: s.isHindi ? 'मैं ' : 'I accept the ',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                                        children: [
                                          TextSpan(
                                            text: s.isHindi ? 'नियम व शर्तें (T&C)' : 'Terms & Conditions',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryGreen,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(text: s.isHindi ? ' और ' : ' and '),
                                          TextSpan(
                                            text: s.isHindi ? 'गोपनीयता नीति' : 'Privacy Policy',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryGreen,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(text: s.isHindi ? ' स्वीकार करता/करती हूँ।' : '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: s.isHindi ? 'कानूनी शर्तें पढ़ें' : 'Read Legal Terms',
                                  icon: const Icon(Icons.info_outline, size: 20, color: AppTheme.primaryGreen),
                                  onPressed: () => TermsAndConditionsDialog.show(context, isHindi: s.isHindi),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: (isLoading || !_acceptedTerms) ? null : _handleCompleteSignup,
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: Text(
                              s.isHindi ? 'खाता बनाएं और प्रवेश करें' : 'Create Account & Enter',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              disabledBackgroundColor: Colors.grey.shade300,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 24),

                      // Optional Google OAuth
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              s.isHindi ? 'या' : 'OR',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                        ],
                      ),
                      const SizedBox(height: 14),

                      OutlinedButton.icon(
                        onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.blue),
                        label: Text(s.googleSignInButton, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
