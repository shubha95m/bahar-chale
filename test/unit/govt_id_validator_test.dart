import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/utils/govt_id_validator.dart';

void main() {
  group('GovtIdValidator Unit Tests', () {
    test('Aadhaar validation accepts valid checksum and rejects invalid ones', () {
      // Known valid Verhoeff Aadhaar test number
      final valid = GovtIdValidator.validateAadhaar('3675 9834 5212');
      expect(valid.isValid, isTrue);
      expect(valid.maskedNumber, 'XXXX XXXX 5212');

      // Invalid length
      final tooShort = GovtIdValidator.validateAadhaar('1234');
      expect(tooShort.isValid, isFalse);

      // Starts with 0 or 1
      final startsWith0 = GovtIdValidator.validateAadhaar('067598345212');
      expect(startsWith0.isValid, isFalse);

      // Corrupted checksum (changed last digit to 9)
      final wrongChecksum = GovtIdValidator.validateAadhaar('367598345219');
      expect(wrongChecksum.isValid, isFalse);
    });

    test('PAN card validation verifies 10 characters and entity code', () {
      final validPan = GovtIdValidator.validatePan('ABCPK1234F');
      expect(validPan.isValid, isTrue);
      expect(validPan.maskedNumber, 'ABCPK****F');

      final lowercasePan = GovtIdValidator.validatePan('abcpk1234f');
      expect(lowercasePan.isValid, isTrue);
      expect(lowercasePan.normalizedNumber, 'ABCPK1234F');

      // Invalid format
      final invalidPan = GovtIdValidator.validatePan('12345ABCDE');
      expect(invalidPan.isValid, isFalse);
    });

    test('Driving License validation checks state code and length', () {
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
