import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../../core/widgets/location_autocomplete_field.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/passenger_request.dart';
import '../providers/passenger_requests_provider.dart';

class CreatePassengerRequestPage extends ConsumerStatefulWidget {
  const CreatePassengerRequestPage({super.key});

  @override
  ConsumerState<CreatePassengerRequestPage> createState() => _CreatePassengerRequestPageState();
}

class _CreatePassengerRequestPageState extends ConsumerState<CreatePassengerRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _originCityController = TextEditingController();
  final _originAreaController = TextEditingController();
  final _destCityController = TextEditingController();
  final _destAreaController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _travelDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _travelTime;
  bool _isTimeFlexible = true;
  int _seatsNeeded = 1;
  String _preferredVehicle = 'any'; // 'any' | 'car' | 'bike'
  double? _originLat;
  double? _originLon;
  double? _destLat;
  double? _destLon;

  @override
  void dispose() {
    _originCityController.dispose();
    _originAreaController.dispose();
    _destCityController.dispose();
    _destAreaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _travelTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _travelTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    final s = ref.read(stringsProvider);
    if (user == null) {
      AppSnackBar.show(context, message: s.isHindi ? 'कृपया पहले साइन इन करें।' : 'Please sign in first.', isError: true);
      return;
    }

    final req = PassengerRequest(
      id: const Uuid().v4(),
      requesterId: user.id,
      originCity: _originCityController.text.trim(),
      originArea: _originAreaController.text.trim().isNotEmpty ? _originAreaController.text.trim() : null,
      originLatitude: _originLat,
      originLongitude: _originLon,
      destinationCity: _destCityController.text.trim(),
      destinationArea: _destAreaController.text.trim().isNotEmpty ? _destAreaController.text.trim() : null,
      destinationLatitude: _destLat,
      destinationLongitude: _destLon,
      travelDate: _travelDate,
      travelTime: _travelTime != null ? '${_travelTime!.hour.toString().padLeft(2, '0')}:${_travelTime!.minute.toString().padLeft(2, '0')}' : null,
      isTimeFlexible: _isTimeFlexible,
      seatsNeeded: _seatsNeeded,
      preferredVehicle: _preferredVehicle,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      status: 'open',
      createdAt: DateTime.now(),
    );

    final res = await ref.read(passengerRequestActionNotifierProvider.notifier).submit(req);

    if (mounted) {
      if (res != null) {
        AppSnackBar.show(
          context,
          message: s.isHindi ? 'आपकी यात्रा की जरूरत पोस्ट हो गई है! चालक आपसे संपर्क कर सकेंगे।' : 'Your travel need has been published! Drivers can now reach out.',
          isSuccess: true,
        );
        context.pop();
      } else {
        AppSnackBar.show(
          context,
          message: s.isHindi ? 'अनुरोध पोस्ट करने में त्रुटि। कृपया पुनः प्रयास करें।' : 'Failed to publish request. Please try again.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final actionState = ref.watch(passengerRequestActionNotifierProvider);
    final isLoading = actionState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.isHindi ? 'सवारी की आवश्यकता पोस्ट करें' : 'Post Ride Request'),
        actions: const [
          LanguageSwitcherButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 90.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.isHindi
                                ? 'अपनी यात्रा का रूट और तारीख साझा करें। उस दिशा में जाने वाले चालक आपकी यह पोस्ट देखकर आपसे सीधे संपर्क कर सकेंगे।'
                                : 'Share your travel itinerary and date. Drivers heading that way can see your request and reach out to offer a ride.',
                            style: const TextStyle(fontSize: 12.5, color: AppTheme.textDark, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Origin City & Area
                  LocationAutocompleteField(
                    controller: _originCityController,
                    labelText: s.originCityLabel,
                    hintText: s.originCityHint,
                    prefixIcon: const Icon(Icons.my_location_rounded, color: AppTheme.primaryGreen),
                    validator: (val) => val == null || val.trim().isEmpty ? s.originCityRequired : null,
                    onSuggestionSelected: (sugg) {
                      _originLat = sugg.latitude;
                      _originLon = sugg.longitude;
                      if (sugg.area != null && _originAreaController.text.trim().isEmpty) {
                        _originAreaController.text = sugg.area!;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _originAreaController,
                    decoration: InputDecoration(
                      labelText: s.originAreaLabel,
                      hintText: s.originAreaHint,
                      prefixIcon: const Icon(Icons.place_outlined, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Destination City & Area
                  LocationAutocompleteField(
                    controller: _destCityController,
                    labelText: s.destinationCityLabel,
                    hintText: s.destinationCityHint,
                    prefixIcon: const Icon(Icons.location_on_rounded, color: AppTheme.accentAmber),
                    validator: (val) => val == null || val.trim().isEmpty ? s.destinationCityRequired : null,
                    onSuggestionSelected: (sugg) {
                      _destLat = sugg.latitude;
                      _destLon = sugg.longitude;
                      if (sugg.area != null && _destAreaController.text.trim().isEmpty) {
                        _destAreaController.text = sugg.area!;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _destAreaController,
                    decoration: InputDecoration(
                      labelText: s.destinationAreaLabel,
                      hintText: s.destinationAreaHint,
                      prefixIcon: const Icon(Icons.place_outlined, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Preferred Vehicle Selector
                  Text(
                    s.isHindi ? 'वाहन की प्राथमिकता:' : 'Vehicle Preference:',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.directions_car_filled_outlined, size: 16),
                          label: Text(s.isHindi ? 'कोई भी' : 'Any'),
                          selected: _preferredVehicle == 'any',
                          selectedColor: AppTheme.primaryGreen,
                          labelStyle: TextStyle(
                            color: _preferredVehicle == 'any' ? Colors.white : AppTheme.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) => setState(() => _preferredVehicle = 'any'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.directions_car_rounded, size: 16),
                          label: Text(s.carText),
                          selected: _preferredVehicle == 'car',
                          selectedColor: AppTheme.primaryGreen,
                          labelStyle: TextStyle(
                            color: _preferredVehicle == 'car' ? Colors.white : AppTheme.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) => setState(() => _preferredVehicle = 'car'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.two_wheeler_rounded, size: 16),
                          label: Text(s.bikeText),
                          selected: _preferredVehicle == 'bike',
                          selectedColor: AppTheme.primaryGreen,
                          labelStyle: TextStyle(
                            color: _preferredVehicle == 'bike' ? Colors.white : AppTheme.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) => setState(() => _preferredVehicle = 'bike'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Seats Needed Stepper
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.isHindi ? 'कितनी सीटें चाहिए?' : 'Seats Needed:',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryGreen, size: 26),
                        onPressed: _seatsNeeded > 1 ? () => setState(() => _seatsNeeded--) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          '$_seatsNeeded',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen, size: 26),
                        onPressed: _seatsNeeded < 4 ? () => setState(() => _seatsNeeded++) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date and Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_rounded, size: 18),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(_travelDate),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time_rounded, size: 18),
                          label: Text(
                            _travelTime != null ? _travelTime!.format(context) : (s.isHindi ? 'लचीला समय' : 'Flexible Time'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  CheckboxListTile(
                    value: _isTimeFlexible,
                    onChanged: (val) => setState(() => _isTimeFlexible = val ?? true),
                    title: Text(s.isHindi ? 'समय में लचीलापन है' : 'Timing is flexible', style: const TextStyle(fontSize: 14)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  // Notes / Luggage details
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: s.isHindi ? 'अतिरिक्त टिप्पणी (उदा. 1 छोटा बैग है, पालतू जानवर नहीं)' : 'Additional Notes (e.g. 1 small bag)',
                      hintText: s.isHindi ? 'चालक के लिए कोई विशेष सूचना' : 'Any note for the driver',
                      prefixIcon: const Icon(Icons.note_alt_outlined, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            s.isHindi ? 'सवारी की आवश्यकता पोस्ट करें' : 'Publish Ride Request',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
