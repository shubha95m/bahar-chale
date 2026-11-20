import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class VerificationSuccessDialog extends StatelessWidget {
  final String userName;
  final String idType;
  final String maskedIdNumber;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final bool isHindi;
  final VoidCallback onDismiss;

  const VerificationSuccessDialog({
    super.key,
    required this.userName,
    required this.idType,
    required this.maskedIdNumber,
    this.avatarBytes,
    this.avatarUrl,
    required this.isHindi,
    required this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required String userName,
    required String idType,
    required String maskedIdNumber,
    Uint8List? avatarBytes,
    String? avatarUrl,
    required bool isHindi,
    required VoidCallback onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VerificationSuccessDialog(
        userName: userName,
        idType: idType,
        maskedIdNumber: maskedIdNumber,
        avatarBytes: avatarBytes,
        avatarUrl: avatarUrl,
        isHindi: isHindi,
        onDismiss: onDismiss,
      ),
    );
  }

  String _formatIdType() {
    switch (idType.toLowerCase()) {
      case 'aadhaar':
        return isHindi ? 'आधार कार्ड (Aadhaar)' : 'Aadhaar Card';
      case 'pan':
        return isHindi ? 'पैन कार्ड (PAN)' : 'PAN Card';
      case 'dl':
        return isHindi ? 'ड्राइविंग लाइसेंस (DL)' : 'Driving License';
      default:
        return isHindi ? 'सरकारी पहचान पत्र (Govt ID)' : 'Government ID';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with top-right Cross (Close) Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppTheme.primaryGreen, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          isHindi ? '100% सत्यापित' : '100% Verified',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dedicated Cross Icon requested by user
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 24, color: AppTheme.textMuted),
                    tooltip: isHindi ? 'बंद करें' : 'Close',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDismiss();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Celebration Icon & Avatar Stack
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                    backgroundImage: avatarBytes != null
                        ? MemoryImage(avatarBytes!)
                        : (avatarUrl != null ? NetworkImage(avatarUrl!) as ImageProvider : null),
                    child: (avatarBytes == null && avatarUrl == null)
                        ? Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Congratulatory Headline
              Text(
                isHindi ? '🎉 बधाई हो! पंजीकरण व पहचान सफल' : '🎉 Congratulations! Verified Successfully',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Greeting & Subtitle
              Text(
                isHindi
                    ? 'नमस्ते $userName, आपकी प्रोफाइल और सरकारी पहचान सफलतापूर्वक सत्यापित हो गई है।'
                    : 'Hello $userName, your profile and Government ID have been verified successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Verification ID Summary Badge Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.badge_rounded, color: AppTheme.primaryGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatIdType(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            maskedIdNumber,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Trust statement
              Text(
                isHindi
                    ? 'सहयात्री और चालक आपकी इस सत्यापित प्रोफाइल को देख सकेंगे, जिससे हर सफर सुरक्षित और विश्वसनीय रहेगा।'
                    : 'Co-travelers and drivers can now see your verified status for complete safety and trust.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.3),
              ),
              const SizedBox(height: 20),

              // Primary Action: Start Journey
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss();
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(
                  isHindi ? 'सवारी शुरू करें (Start Travelling)' : 'Start Travelling',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
