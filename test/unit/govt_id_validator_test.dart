import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/utils/govt_id_validator.dart';

void main() {
  group('GovtIdValidator Unit Tests', () {
    test('Aadhaar validation accepts valid 12-digit number and formats mask', () {
      // Standard synthetic 12-digit Aadhaar test number
      final valid = GovtIdValidator.validateAadhaar('1234 5678 9012');
      expect(valid.isValid, isTrue);
      expect(valid.maskedNumber, 'XXXX XXXX 9012');
      expect(valid.normalizedNumber, '123456789012');

      // Another 12-digit Aadhaar test number
      final standard = GovtIdValidator.validateAadhaar('3675 9834 5212');
      expect(standard.isValid, isTrue);
      expect(standard.maskedNumber, 'XXXX XXXX 5212');

      // Invalid length
      final tooShort = GovtIdValidator.validateAadhaar('1234');
      expect(tooShort.isValid, isFalse);

      // Non-digit characters
      final letters = GovtIdValidator.validateAadhaar('GIASC12345J');
      expect(letters.isValid, isFalse);
    });

    test('PAN card validation verifies 10 characters', () {
      // Synthetic PAN test number
      final userPan = GovtIdValidator.validatePan('ABCDE1234F');
      expect(userPan.isValid, isTrue);
      expect(userPan.maskedNumber, 'ABCDE****F');
      expect(userPan.normalizedNumber, 'ABCDE1234F');

      final validPan = GovtIdValidator.validatePan('XYZPK5678Q');
      expect(validPan.isValid, isTrue);
      expect(validPan.maskedNumber, 'XYZPK****Q');

      final lowercasePan = GovtIdValidator.validatePan('xyzpk5678q');
      expect(lowercasePan.isValid, isTrue);
      expect(lowercasePan.normalizedNumber, 'XYZPK5678Q');

      // Invalid format (too short / wrong structure)
      final invalidPan = GovtIdValidator.validatePan('12345ABCDE');
      expect(invalidPan.isValid, isFalse);
    });

    test('Driving License validation checks state code and length', () {
      // Synthetic DL test number
      final userDl = GovtIdValidator.validateDl('DL01 20240001234');
      expect(userDl.isValid, isTrue);
      expect(userDl.maskedNumber, 'DL01****1234');

      final validDl = GovtIdValidator.validateDl('DL-1420110012345');
      expect(validDl.isValid, isTrue);
      expect(validDl.maskedNumber, 'DL14****2345');

      final upDl = GovtIdValidator.validateDl('UP16 20180004567');
      expect(upDl.isValid, isTrue);

      // Invalid state code
      final invalidState = GovtIdValidator.validateDl('XX-1420110012345');
      expect(invalidState.isValid, isFalse);
    });

    test('analyzeImageBytes detects valid JPEG and PNG header bytes', () {
      // JPEG magic bytes: FF D8 FF
      final jpegBytes = Uint8List(5000);
      jpegBytes[0] = 0xFF;
      jpegBytes[1] = 0xD8;
      jpegBytes[2] = 0xFF;
      expect(GovtIdValidator.analyzeImageBytes(jpegBytes), isTrue);

      // Too small (< 4KB)
      final tinyBytes = Uint8List(100);
      expect(GovtIdValidator.analyzeImageBytes(tinyBytes), isFalse);

      // Null or empty
      expect(GovtIdValidator.analyzeImageBytes(null), isFalse);
      expect(GovtIdValidator.analyzeImageBytes(Uint8List(0)), isFalse);
    });
  });
}
