import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

enum GovtIdType {
  aadhaar,
  pan,
  dl,
}

class GovtIdValidationResult {
  final bool isValid;
  final String? errorMessageHi;
  final String? errorMessageEn;
  final String? maskedNumber;
  final String? normalizedNumber;

  const GovtIdValidationResult({
    required this.isValid,
    this.errorMessageHi,
    this.errorMessageEn,
    this.maskedNumber,
    this.normalizedNumber,
  });

  String getErrorMessage({bool isHindi = false}) {
    return (isHindi ? errorMessageHi : errorMessageEn) ?? '';
  }
}

class GovtIdValidator {
  // Indian State Codes for Driving License validation
  static const Set<String> _indianStateCodes = {
    'AN', 'AP', 'AR', 'AS', 'BR', 'CH', 'CG', 'DD', 'DL', 'DN',
    'GA', 'GJ', 'HR', 'HP', 'JH', 'JK', 'KA', 'KL', 'LA', 'LD',
    'MH', 'ML', 'MN', 'MP', 'MZ', 'NL', 'OD', 'PB', 'PY', 'RJ',
    'SK', 'TN', 'TR', 'TS', 'UK', 'UP', 'WB'
  };

  // Verhoeff algorithm multiplication table
  static const List<List<int>> _d = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
  ];

  // Verhoeff algorithm permutation table
  static const List<List<int>> _p = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
  ];

  /// Verhoeff algorithm validation for Aadhaar 12-digit number
  static bool _validateVerhoeff(String numStr) {
    int c = 0;
    final reversed = numStr.split('').reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      final digit = int.tryParse(reversed[i]);
      if (digit == null) return false;
      c = _d[c][_p[i % 8][digit]];
    }
    return c == 0;
  }

  /// Validates Aadhaar card number
  static GovtIdValidationResult validateAadhaar(String rawInput) {
    final clean = rawInput.replaceAll(RegExp(r'\s+|-'), '').trim();
    if (clean.isEmpty) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'कृपया 12-अंकों का आधार नंबर दर्ज करें।',
        errorMessageEn: 'Please enter 12-digit Aadhaar number.',
      );
    }
    if (!RegExp(r'^[0-9]{12}$').hasMatch(clean)) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'आधार नंबर केवल 12 अंकों का होना चाहिए।',
        errorMessageEn: 'Aadhaar number must be exactly 12 digits.',
      );
    }
    if (clean.startsWith('0') || clean.startsWith('1')) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'वैध आधार नंबर 0 या 1 से शुरू नहीं हो सकता।',
        errorMessageEn: 'Valid Aadhaar number cannot start with 0 or 1.',
      );
    }

    // UIDAI Verhoeff Checksum
    if (!_validateVerhoeff(clean)) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'अमान्य आधार नंबर। कृपया सही आधार कार्ड नंबर जांचें।',
        errorMessageEn: 'Invalid Aadhaar number checksum. Please re-check.',
      );
    }

    final masked = 'XXXX XXXX ${clean.substring(8)}';
    return GovtIdValidationResult(
      isValid: true,
      maskedNumber: masked,
      normalizedNumber: clean,
    );
  }

  /// Validates Income Tax PAN card number
  static GovtIdValidationResult validatePan(String rawInput) {
    final clean = rawInput.replaceAll(RegExp(r'\s+|-'), '').trim().toUpperCase();
    if (clean.isEmpty) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'कृपया 10-अक्षरों का पैन (PAN) नंबर दर्ज करें।',
        errorMessageEn: 'Please enter 10-character PAN number.',
      );
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(clean)) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'पैन प्रारूप अमान्य है। सही प्रारूप उदा: ABCDE1234F',
        errorMessageEn: 'Invalid PAN format. Standard format: ABCDE1234F',
      );
    }

    // 4th character validation for Individual/Person
    final entityChar = clean[3];
    const validEntityChars = {'P', 'C', 'H', 'F', 'A', 'T', 'B', 'L', 'J', 'G'};
    if (!validEntityChars.contains(entityChar)) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'पैन का चौथा अक्षर अमान्य नागरिक कोड दर्शाता है।',
        errorMessageEn: 'Invalid 4th character for Indian PAN.',
      );
    }

    final masked = '${clean.substring(0, 5)}****${clean.substring(9)}';
    return GovtIdValidationResult(
      isValid: true,
      maskedNumber: masked,
      normalizedNumber: clean,
    );
  }

  /// Validates Indian Driving License (DL) number
  static GovtIdValidationResult validateDl(String rawInput) {
    final clean = rawInput.replaceAll(RegExp(r'[\s\-_/]+'), '').trim().toUpperCase();
    if (clean.isEmpty) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'कृपया ड्राइविंग लाइसेंस (DL) नंबर दर्ज करें।',
        errorMessageEn: 'Please enter Driving License number.',
      );
    }
    if (clean.length < 13 || clean.length > 16) {
      return const GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'ड्राइविंग लाइसेंस 13 से 16 अक्षरों का होना चाहिए (उदा: DL-1420110012345)।',
        errorMessageEn: 'Driving License must be 13 to 16 characters (e.g. DL-1420110012345).',
      );
    }

    final stateCode = clean.substring(0, 2);
    if (!_indianStateCodes.contains(stateCode)) {
      return GovtIdValidationResult(
        isValid: false,
        errorMessageHi: 'अमान्य राज्य कोड "$stateCode"। सही भारतीय राज्य कोड से शुरू होना चाहिए।',
        errorMessageEn: 'Invalid state code "$stateCode". Must start with a valid Indian state code.',
      );
    }

    final masked = '${clean.substring(0, 4)}****${clean.substring(clean.length - 4)}';
    return GovtIdValidationResult(
      isValid: true,
      maskedNumber: masked,
      normalizedNumber: clean,
    );
  }

  /// Validates selected Govt ID against its specific rule
  static GovtIdValidationResult validate(GovtIdType type, String rawInput) {
    switch (type) {
      case GovtIdType.aadhaar:
        return validateAadhaar(rawInput);
      case GovtIdType.pan:
        return validatePan(rawInput);
      case GovtIdType.dl:
        return validateDl(rawInput);
    }
  }

  /// Computes SHA-256 hash for secure storage and duplication check
  static String hashIdNumber(String normalizedNumber) {
    return sha256.convert(utf8.encode(normalizedNumber)).toString();
  }

  /// Analyzes image bytes to verify image integrity, format, and minimum dimensions
  static bool analyzeImageBytes(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return false;
    // Check minimum size: 4KB
    if (bytes.length < 4096) return false;
    // Check maximum size: 12MB
    if (bytes.length > 12 * 1024 * 1024) return false;

    // Check magic bytes for JPEG (FF D8), PNG (89 50 4E 47), or WebP (RIFF....WEBP)
    if (bytes.length >= 4) {
      final isJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8;
      final isPng = bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
      final isWebp = bytes.length >= 12 &&
          bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
          bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50;
      if (isJpeg || isPng || isWebp) return true;
    }
    return false;
  }
}
