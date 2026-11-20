import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class VerificationProgressDialog extends StatefulWidget {
  final bool isHindi;

  const VerificationProgressDialog({super.key, required this.isHindi});

  /// Displays the backend verification progress dialog.
  /// Returns a controller to close the dialog when verification finishes.
  static BuildContext? _activeContext;

  static void show(BuildContext context, {required bool isHindi}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _activeContext = ctx;
        return VerificationProgressDialog(isHindi: isHindi);
      },
    );
  }

  static void dismiss() {
    if (_activeContext != null) {
      try {
        if (Navigator.canPop(_activeContext!)) {
          Navigator.pop(_activeContext!);
        }
      } catch (_) {}
      _activeContext = null;
    }
  }

  @override
  State<VerificationProgressDialog> createState() => _VerificationProgressDialogState();
}

class _VerificationProgressDialogState extends State<VerificationProgressDialog> {
  double _progress = 0.15;
  int _activeStep = 0;
  Timer? _timer;

  List<String> get _steps => widget.isHindi
      ? [
          'दस्तावेज़ फोटो स्पष्टता व बाइट्स की जांच...',
          'सरकारी पहचान पत्र प्रारूप व संख्या का सत्यापन...',
          'धोखाधड़ी रोकथाम व डुप्लिकेट रिकॉर्ड की जांच...',
          'सत्यापित नागरिक रिकॉर्ड अंतिम रूप से दर्ज...',
        ]
      : [
          'Analyzing document photo clarity & magic bytes...',
          'Verifying official Government ID format & structure...',
          'Running fraud prevention & deduplication check...',
          'Finalizing verified citizen trust record...',
        ];

  @override
  void initState() {
    super.initState();
    _startProgressAnimation();
  }

  void _startProgressAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 0.90) {
          _progress += 0.22;
          if (_progress > 0.90) _progress = 0.90;
        }
        if (_progress > 0.70) {
          _activeStep = 3;
        } else if (_progress > 0.45) {
          _activeStep = 2;
        } else if (_progress > 0.20) {
          _activeStep = 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = widget.isHindi;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Animated Shield Header
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                        strokeWidth: 3.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                isHindi
                    ? 'सर्वर पर दस्तावेज़ का सत्यापन हो रहा है...'
                    : 'Verifying Documents in Backend...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // "Please Relax" Reassurance Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.spa_rounded, color: AppTheme.primaryGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isHindi
                            ? 'कृपया निश्चिंत रहें! हमारा सुरक्षित बैकएंड इंजन दस्तावेज़ की प्रामाणिकता जांच रहा है।'
                            : 'Please relax! Our secure backend engine is verifying your document authenticity and reliability.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Animated Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: AppTheme.primaryGreen,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic Step Checklist
              ...List.generate(_steps.length, (idx) {
                final isDone = idx < _activeStep;
                final isCurrent = idx == _activeStep;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      if (isDone)
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16)
                      else if (isCurrent)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryGreen,
                          ),
                        )
                      else
                        Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade400, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _steps[idx],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDone || isCurrent ? AppTheme.textDark : AppTheme.textMuted,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
