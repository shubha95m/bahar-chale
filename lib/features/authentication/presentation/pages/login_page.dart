import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../providers/auth_provider.dart';

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

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        backgroundColor: isError ? Colors.red.shade800 : AppTheme.primaryGreen,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'ठीक है',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
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
      _showSnack('6-अंकों का OTP कोड आपके ईमेल ($email) पर भेजा गया है!');
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
      _showSnack('ईमेल सफलतापूर्वक सत्यापित हुआ! अब अपना पासवर्ड बनाएं।');
    }
  }

  // --- Sign Up Step 3: Set Password & Finish ---
  Future<void> _handleCompleteSignup() async {
    final name = _signupNameController.text.trim();
    final password = _signupPasswordController.text;
    final confirmPassword = _signupConfirmPasswordController.text;

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
    );

    if (success && mounted) {
      _showSnack('पंजीकरण सफल! आपका स्वागत है।');
      // GoRouter automatically redirects to home upon successful session
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
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
                      // Logo & App Name
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
                      const Text(
                        AppStrings.appNameHindi,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        AppStrings.tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tabs: Sign In vs Sign Up with OTP
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
                                    'साइन इन (लॉगिन)',
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
                                    'नया खाता (OTP)',
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
                          decoration: const InputDecoration(
                            labelText: 'ईमेल पता (Email) *',
                            hintText: 'उदा. your.name@gmail.com',
                            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _loginPasswordController,
                          obscureText: _obscureLoginPassword,
                          decoration: InputDecoration(
                            labelText: 'पासवर्ड (Password) *',
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
                                'एक बार लॉगिन करने पर अगली बार ऑटो-लॉगिन रहेगा',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('साइन इन करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],

                      // TAB 1: Sign Up with Real Email + OTP Verification
                      if (_selectedTab == 1) ...[
                        // Step 1: Name and Real Email
                        if (_signupStep == 1) ...[
                          TextField(
                            controller: _signupNameController,
                            decoration: const InputDecoration(
                              labelText: 'आपका पूरा नाम *',
                              hintText: 'उदा. राहुल शर्मा',
                              prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _signupEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'असली ईमेल पता (Gmail / Other) *',
                              hintText: 'उदा. shubham@gmail.com',
                              prefixIcon: Icon(Icons.mark_email_read_outlined, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '🛡️ केवल असली ईमेल मान्य है। सत्यापन हेतु 6-अंकों का OTP भेजा जाएगा।',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _handleSendOtp,
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('ईमेल पर OTP भेजें', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              minimumSize: const Size.fromHeight(48),
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
                                  child: Text(
                                    '${_signupEmailController.text.trim()} पर 6-अंकों का OTP भेजा गया है।',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
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
                            decoration: const InputDecoration(
                              labelText: '6-अंकों का OTP दर्ज करें *',
                              counterText: '',
                              prefixIcon: Icon(Icons.pin_outlined, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _handleVerifyOtp,
                            icon: const Icon(Icons.verified_outlined, size: 18),
                            label: const Text('OTP सत्यापित करें', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _signupStep = 1),
                                child: const Text('ईमेल बदलें', style: TextStyle(fontSize: 12)),
                              ),
                              TextButton(
                                onPressed: isLoading ? null : _handleSendOtp,
                                child: const Text('OTP पुनः भेजें', style: TextStyle(fontSize: 12)),
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
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ईमेल सत्यापित हो गया! अब अपना लॉगिन पासवर्ड बनाएं:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
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
                              labelText: 'नया पासवर्ड बनाएं (कम से कम 6 अक्षर) *',
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
                            decoration: const InputDecoration(
                              labelText: 'पासवर्ड की पुष्टि करें *',
                              prefixIcon: Icon(Icons.lock_reset, color: AppTheme.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _handleCompleteSignup,
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('खाता बनाएं और प्रवेश करें', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 24),

                      // Divider for Google / Demo options
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'या त्वरित परीक्षण (Quick Test)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Demo 1-Click Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).signInAsDemoUser(asDriver: true),
                              icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.white),
                              label: const Text('चालक (Driver)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).signInAsDemoUser(asDriver: false),
                              icon: const Icon(Icons.person_search_rounded, size: 16, color: AppTheme.accentAmber),
                              label: const Text('यात्री (Rider)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentAmber)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.accentAmber, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Google Sign In (for when admin configures provider)
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 26, color: Colors.blue),
                        label: const Text('Google से साइन इन करें', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
