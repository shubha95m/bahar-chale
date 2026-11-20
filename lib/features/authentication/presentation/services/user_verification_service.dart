import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../../../core/utils/govt_id_validator.dart';

class VerificationPayload {
  final Uint8List profilePictureBytes;
  final String profilePictureFilename;
  final GovtIdType idType;
  final String idNumber;
  final Uint8List idFrontBytes;
  final String idFrontFilename;
  final Uint8List? idBackBytes;
  final String? idBackFilename;

  const VerificationPayload({
    required this.profilePictureBytes,
    required this.profilePictureFilename,
    required this.idType,
    required this.idNumber,
    required this.idFrontBytes,
    required this.idFrontFilename,
    this.idBackBytes,
    this.idBackFilename,
  });
}

class UserVerificationService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Uploads user avatar, ID documents, and records verified profile data
  static Future<Map<String, dynamic>> submitVerification({
    required String userId,
    required VerificationPayload payload,
  }) async {
    // 1. Validate ID Number
    final validation = GovtIdValidator.validate(payload.idType, payload.idNumber);
    if (!validation.isValid) {
      throw FormatException(validation.errorMessageEn ?? 'Invalid Government ID number.');
    }

    // 2. Analyze Profile Picture and ID document images
    if (!GovtIdValidator.analyzeImageBytes(payload.profilePictureBytes)) {
      throw const FormatException('Profile picture is invalid or too small. Please upload a clear photo.');
    }
    if (!GovtIdValidator.analyzeImageBytes(payload.idFrontBytes)) {
      throw const FormatException('Front ID document image is invalid. Please upload a clear photo.');
    }
    if (payload.idType == GovtIdType.aadhaar) {
      if (payload.idBackBytes == null || !GovtIdValidator.analyzeImageBytes(payload.idBackBytes)) {
        throw const FormatException('Aadhaar requires both Front and Back sides. Please upload the back photo.');
      }
    }

    final idTypeStr = payload.idType == GovtIdType.aadhaar
        ? 'aadhaar'
        : (payload.idType == GovtIdType.pan ? 'pan' : 'dl');
    final maskedNumber = validation.maskedNumber!;
    final idHash = GovtIdValidator.hashIdNumber(validation.normalizedNumber!);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 3. Upload Profile Picture to 'avatars' bucket
    final avatarPath = '$userId/avatar_$timestamp.jpg';
    await _client.storage.from('avatars').uploadBinary(
          avatarPath,
          payload.profilePictureBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    final avatarUrl = _client.storage.from('avatars').getPublicUrl(avatarPath);

    // 4. Upload Front ID to 'id_documents' bucket
    final frontDocPath = '$userId/id_front_$timestamp.jpg';
    await _client.storage.from('id_documents').uploadBinary(
          frontDocPath,
          payload.idFrontBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    final frontDocUrl = _client.storage.from('id_documents').getPublicUrl(frontDocPath);

    // 5. Upload Back ID if Aadhaar
    String? backDocUrl;
    if (payload.idType == GovtIdType.aadhaar && payload.idBackBytes != null) {
      final backDocPath = '$userId/id_back_$timestamp.jpg';
      await _client.storage.from('id_documents').uploadBinary(
            backDocPath,
            payload.idBackBytes!,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      backDocUrl = _client.storage.from('id_documents').getPublicUrl(backDocPath);
    }

    // 6. Update user profile with verified status
    final nowIso = DateTime.now().toUtc().toIso8601String();
    await _client.from('profiles').update({
      'avatar_url': avatarUrl,
      'id_type': idTypeStr,
      'id_number_masked': maskedNumber,
      'id_number_hash': idHash,
      'id_front_url': frontDocUrl,
      'id_back_url': backDocUrl,
      'id_verified': true,
      'id_verified_at': nowIso,
      'verification_status': 'verified',
    }).eq('id', userId);

    return {
      'avatar_url': avatarUrl,
      'id_type': idTypeStr,
      'id_number_masked': maskedNumber,
      'id_verified': true,
      'verification_status': 'verified',
    };
  }
}
