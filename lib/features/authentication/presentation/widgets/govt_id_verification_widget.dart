import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/govt_id_validator.dart';
import '../services/user_verification_service.dart';
import 'verification_success_dialog.dart';

class GovtIdVerificationWidget extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  final VoidCallback onCompleted;
  final bool isStandalone;

  const GovtIdVerificationWidget({
    super.key,
    required this.userId,
    required this.userName,
    required this.onCompleted,
    this.isStandalone = false,
  });

  @override
  ConsumerState<GovtIdVerificationWidget> createState() => _GovtIdVerificationWidgetState();
}

class _GovtIdVerificationWidgetState extends ConsumerState<GovtIdVerificationWidget> {
  final _picker = ImagePicker();
  final _idNumberController = TextEditingController();

  GovtIdType _selectedIdType = GovtIdType.aadhaar;
  Uint8List? _profilePicBytes;
  String? _profilePicName;

  Uint8List? _frontDocBytes;
  String? _frontDocName;

  Uint8List? _backDocBytes;
  String? _backDocName;

  bool _isSubmitting = false;
  String? _validationError;

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _profilePicBytes = bytes;
          _profilePicName = file.name;
          _validationError = null;
        });
      }
    } catch (e) {
      setState(() => _validationError = 'Error picking profile photo: $e');
    }
  }

  Future<void> _pickFrontDoc() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _frontDocBytes = bytes;
          _frontDocName = file.name;
          _validationError = null;
        });
      }
    } catch (e) {
      setState(() => _validationError = 'Error picking document photo: $e');
    }
  }

  Future<void> _pickBackDoc() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _backDocBytes = bytes;
          _backDocName = file.name;
          _validationError = null;
        });
      }
    } catch (e) {
      setState(() => _validationError = 'Error picking back document photo: $e');
    }
  }

  Future<void> _handleSubmit(AppStrings s) async {
    setState(() => _validationError = null);

    // 1. Profile Picture Check
    if (_profilePicBytes == null) {
      setState(() => _validationError = s.isHindi
          ? 'कृपया अपनी स्पष्ट प्रोफ़ाइल तस्वीर (सेल्फी/फोटो) अपलोड करें।'
          : 'Please upload a clear profile picture / portrait photo.');
      return;
    }

    // 2. ID Number Validation
    final idNumber = _idNumberController.text.trim();
    final result = GovtIdValidator.validate(_selectedIdType, idNumber);
    if (!result.isValid) {
      setState(() => _validationError = result.getErrorMessage(isHindi: s.isHindi));
      return;
    }

    // 3. Document Photos Check
    if (_frontDocBytes == null) {
      setState(() => _validationError = s.isHindi
          ? 'कृपया पहचान पत्र के सामने वाले भाग की फोटो अपलोड करें।'
          : 'Please upload the front side photo of your Govt ID.');
      return;
    }

    if (_selectedIdType == GovtIdType.aadhaar && _backDocBytes == null) {
      setState(() => _validationError = s.isHindi
          ? 'आधार कार्ड के लिए आगे और पीछे (दोनों तरफ) की फोटो अनिवार्य है।'
          : 'Aadhaar Card requires both Front and Back side photos.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = VerificationPayload(
        profilePictureBytes: _profilePicBytes!,
        profilePictureFilename: _profilePicName ?? 'profile.jpg',
        idType: _selectedIdType,
        idNumber: idNumber,
        idFrontBytes: _frontDocBytes!,
        idFrontFilename: _frontDocName ?? 'id_front.jpg',
        idBackBytes: _backDocBytes,
        idBackFilename: _backDocName,
      );

      final res = await UserVerificationService.submitVerification(
        userId: widget.userId,
        payload: payload,
      );

      if (!mounted) return;

      // Show Congratulatory Popup with Cross Icon
      final idTypeStr = _selectedIdType == GovtIdType.aadhaar
          ? 'aadhaar'
          : (_selectedIdType == GovtIdType.pan ? 'pan' : 'dl');

      VerificationSuccessDialog.show(
        context,
        userName: widget.userName,
        idType: idTypeStr,
        maskedIdNumber: res['id_number_masked'] ?? result.maskedNumber ?? '',
        avatarBytes: _profilePicBytes,
        isHindi: s.isHindi,
        onDismiss: () {
          widget.onCompleted();
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _validationError = e.toString().replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trust Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppTheme.primaryGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.isHindi ? 'नागरिक पहचान व प्रोफ़ाइल सत्यापन' : 'Citizen ID & Profile Verification',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                    ),
                    Text(
                      s.isHindi ? 'सुरक्षित व विश्वसनीय यात्रा हेतु अनिवार्य' : 'Mandatory for trusted community travel',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Profile Picture Section
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFFE2E8F0),
                      backgroundImage: _profilePicBytes != null ? MemoryImage(_profilePicBytes!) : null,
                      child: _profilePicBytes == null
                          ? const Icon(Icons.person_rounded, size: 48, color: AppTheme.textMuted)
                          : null,
                    ),
                    InkWell(
                      onTap: _pickProfilePicture,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickProfilePicture,
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: Text(
                    _profilePicBytes == null
                        ? (s.isHindi ? 'प्रोफ़ाइल फोटो अपलोड करें *' : 'Upload Profile Photo *')
                        : (s.isHindi ? 'फोटो बदलें' : 'Change Photo'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Text(
                  s.isHindi ? 'स्पष्ट चेहरे की सीधी तस्वीर अपलोड करें।' : 'Upload a clear front-facing portrait photo.',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // 2. Govt ID Selector
          Text(
            s.isHindi ? 'सरकारी पहचान पत्र चुनें *' : 'Select Government ID *',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                selectedColor: AppTheme.primaryGreen.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryGreen,
                label: Text(s.isHindi ? 'आधार कार्ड (Aadhaar)' : 'Aadhaar Card'),
                selected: _selectedIdType == GovtIdType.aadhaar,
                onSelected: (val) {
                  if (val && _selectedIdType != GovtIdType.aadhaar) {
                    setState(() {
                      _selectedIdType = GovtIdType.aadhaar;
                      _idNumberController.clear();
                      _validationError = null;
                    });
                  }
                },
              ),
              ChoiceChip(
                selectedColor: AppTheme.primaryGreen.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryGreen,
                label: Text(s.isHindi ? 'पैन कार्ड (PAN)' : 'PAN Card'),
                selected: _selectedIdType == GovtIdType.pan,
                onSelected: (val) {
                  if (val && _selectedIdType != GovtIdType.pan) {
                    setState(() {
                      _selectedIdType = GovtIdType.pan;
                      _idNumberController.clear();
                      _validationError = null;
                    });
                  }
                },
              ),
              ChoiceChip(
                selectedColor: AppTheme.primaryGreen.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryGreen,
                label: Text(s.isHindi ? 'ड्राइविंग लाइसेंस (DL)' : 'Driving License'),
                selected: _selectedIdType == GovtIdType.dl,
                onSelected: (val) {
                  if (val && _selectedIdType != GovtIdType.dl) {
                    setState(() {
                      _selectedIdType = GovtIdType.dl;
                      _idNumberController.clear();
                      _validationError = null;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. ID Number Input
          Text(
            _selectedIdType == GovtIdType.aadhaar
                ? (s.isHindi ? '12-अंकों का आधार नंबर *' : '12-Digit Aadhaar Number *')
                : (_selectedIdType == GovtIdType.pan
                    ? (s.isHindi ? '10-अक्षरों का पैन कार्ड नंबर *' : '10-Character PAN Number *')
                    : (s.isHindi ? 'ड्राइविंग लाइसेंस नंबर *' : 'Driving License Number *')),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _idNumberController,
            textCapitalization: _selectedIdType == GovtIdType.aadhaar
                ? TextCapitalization.none
                : TextCapitalization.characters,
            keyboardType: _selectedIdType == GovtIdType.aadhaar
                ? TextInputType.number
                : TextInputType.text,
            maxLength: _selectedIdType == GovtIdType.aadhaar
                ? 14
                : (_selectedIdType == GovtIdType.pan ? 10 : 16),
            decoration: InputDecoration(
              counterText: '',
              hintText: _selectedIdType == GovtIdType.aadhaar
                  ? (s.isHindi ? 'उदा. 8201 4019 3698' : 'e.g. 8201 4019 3698')
                  : (_selectedIdType == GovtIdType.pan
                      ? (s.isHindi ? 'उदा. GIJPS9957M' : 'e.g. GIJPS9957M')
                      : (s.isHindi ? 'उदा. RJ09 20200005545' : 'e.g. RJ09 20200005545')),
              prefixIcon: const Icon(Icons.credit_card_rounded, color: AppTheme.primaryGreen),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 18),

          // 4. Document Photos Upload Cards
          Text(
            _selectedIdType == GovtIdType.aadhaar
                ? (s.isHindi ? 'पहचान पत्र की दोनों तरफ की फोटो *' : 'Upload ID Photos (Front & Back Required) *')
                : (s.isHindi ? 'पहचान पत्र की फोटो (सामने का भाग) *' : 'Upload ID Photo (Front Side) *'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
          ),
          const SizedBox(height: 10),

          // Front Upload Card
          _buildUploadCard(
            title: s.isHindi ? 'सामने का भाग (Front Side) *' : 'Front Side Photo *',
            subtitle: s.isHindi ? 'नाम और फोटो स्पष्ट रूप से दिखनी चाहिए।' : 'Name and photo must be clearly visible.',
            bytes: _frontDocBytes,
            filename: _frontDocName,
            onPick: _pickFrontDoc,
            isHindi: s.isHindi,
          ),

          // Back Upload Card (If Aadhaar)
          if (_selectedIdType == GovtIdType.aadhaar) ...[
            const SizedBox(height: 10),
            _buildUploadCard(
              title: s.isHindi ? 'पिछला भाग (Back Side with Address) *' : 'Back Side Photo (with Address) *',
              subtitle: s.isHindi ? 'पते वाला भाग स्पष्ट रूप से दिखना चाहिए।' : 'Address side must be clearly visible.',
              bytes: _backDocBytes,
              filename: _backDocName,
              onPick: _pickBackDoc,
              isHindi: s.isHindi,
            ),
          ],

          if (_validationError != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationError!,
                      style: TextStyle(fontSize: 12.5, color: Colors.red.shade900, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),

          // Submit & Verify Button
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () => _handleSubmit(s),
            icon: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.verified_user_rounded, size: 20),
            label: Text(
              _isSubmitting
                  ? (s.isHindi ? 'दस्तावेज़ सत्यापित हो रहे हैं...' : 'Verifying Documents...')
                  : (s.isHindi ? 'पहचान सत्यापित करें और पंजीकरण पूरा करें' : 'Verify ID & Complete Registration'),
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required Uint8List? bytes,
    required String? filename,
    required VoidCallback onPick,
    required bool isHindi,
  }) {
    final hasUploaded = bytes != null;

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasUploaded ? AppTheme.primaryGreen.withOpacity(0.05) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasUploaded ? AppTheme.primaryGreen : const Color(0xFFCBD5E1),
            width: hasUploaded ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            if (hasUploaded)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  bytes,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.upload_file_rounded, color: AppTheme.textMuted, size: 28),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: hasUploaded ? AppTheme.primaryGreen : AppTheme.textDark,
                          ),
                        ),
                      ),
                      if (hasUploaded)
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasUploaded
                        ? (filename ?? (isHindi ? 'दस्तावेज़ अपलोड हो गया' : 'Document uploaded'))
                        : subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: hasUploaded ? AppTheme.textDark : AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onPick,
              child: Text(
                hasUploaded
                    ? (isHindi ? 'बदलें (Change)' : 'Change')
                    : (isHindi ? 'अपलोड करें (Upload)' : 'Upload'),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
