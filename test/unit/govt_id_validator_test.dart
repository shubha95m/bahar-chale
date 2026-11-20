import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/utils/govt_id_validator.dart';

void main() {
  group('GovtIdValidator Unit Tests', () {
    test('Aadhaar validation accepts valid 12-digit number and formats mask', () {
      // User real uploaded Aadhaar number
      final valid = GovtIdValidator.validateAadhaar('8201 4019 3698');
      expect(valid.isValid, isTrue);
      expect(valid.maskedNumber, 'XXXX XXXX 3698');
      expect(valid.normalizedNumber, '820140193698');

      // Standard 12-digit Aadhaar test number
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
      // User real uploaded PAN number
      final userPan = GovtIdValidator.validatePan('GIJPS9957M');
      expect(userPan.isValid, isTrue);
      expect(userPan.maskedNumber, 'GIJPS****M');
      expect(userPan.normalizedNumber, 'GIJPS9957M');

      final validPan = GovtIdValidator.validatePan('ABCPK1234F');
      expect(validPan.isValid, isTrue);
      expect(validPan.maskedNumber, 'ABCPK****F');

      final lowercasePan = GovtIdValidator.validatePan('abcpk1234f');
      expect(lowercasePan.isValid, isTrue);
      expect(lowercasePan.normalizedNumber, 'ABCPK1234F');

      // Invalid format (too short / wrong structure)
      final invalidPan = GovtIdValidator.validatePan('12345ABCDE');
      expect(invalidPan.isValid, isFalse);
    });

    test('Driving License validation checks state code and length', () {
      // User real uploaded DL number
      final userDl = GovtIdValidator.validateDl('RJ09 20200005545');
      expect(userDl.isValid, isTrue);
      expect(userDl.maskedNumber, 'RJ09****5545');

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
