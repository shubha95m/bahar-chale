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
import '../../../authentication/presentation/widgets/govt_document_gate_dialog.dart';
import '../../domain/entities/ride.dart';
import '../providers/rides_provider.dart';

class CreateRidePage extends ConsumerStatefulWidget {
  const CreateRidePage({super.key});

  @override
  ConsumerState<CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends ConsumerState<CreateRidePage> {
  final _formKey = GlobalKey<FormState>();
  final _originCityController = TextEditingController();
  final _originAreaController = TextEditingController();
  final _destCityController = TextEditingController();
  final _destAreaController = TextEditingController();
  final _contributionController = TextEditingController();
  final _notesController = TextEditingController();

  String _rideCategory = 'private_vehicle'; // 'private_vehicle' | 'general_travel'
  String _vehicleType = 'car';
  DateTime _travelDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _travelTime;
  bool _isTimeFlexible = true;
  int _seats = 4;
  double? _originLat;
  double? _originLon;
  double? _destLat;
  double? _destLon;

  int get _maxSeatsForVehicle {
    if (_rideCategory == 'general_travel') return 8;
    switch (_vehicleType) {
      case 'bike':
        return 3;
      case 'car':
        return 8;
      default:
        return 12;
    }
  }

  void _onVehicleChanged(String type) {
    setState(() {
      _vehicleType = type;
      if (type == 'bike') {
        _seats = 1;
      } else if (type == 'car') {
        _seats = 4;
      } else {
        _seats = 6;
      }
    });
  }

  @override
  void dispose() {
    _originCityController.dispose();
    _originAreaController.dispose();
    _destCityController.dispose();
    _destAreaController.dispose();
    _contributionController.dispose();
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

    final allowed = await GovtDocumentGateDialog.ensureVerified(context, ref);
    if (!allowed || !mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      AppSnackBar.show(
        context,
        message: ref.read(stringsProvider).isHindi ? 'कृपया पहले साइन इन करें।' : 'Please sign in first.',
        isError: true,
      );
      return;
    }

    final contribution = _contributionController.text.trim().isNotEmpty
        ? double.tryParse(_contributionController.text.trim())
        : null;

    final formattedTime = _travelTime != null
        ? '${_travelTime!.hour.toString().padLeft(2, '0')}:${_travelTime!.minute.toString().padLeft(2, '0')}:00'
        : null;

    final ride = Ride(
      id: const Uuid().v4(),
      ownerId: user.id,
      rideCategory: _rideCategory,
      vehicleType: _rideCategory == 'private_vehicle' ? _vehicleType : null,
      originCity: _originCityController.text.trim(),
      originArea: _originAreaController.text.trim().isNotEmpty ? _originAreaController.text.trim() : null,
      originLatitude: _originLat,
      originLongitude: _originLon,
      destinationCity: _destCityController.text.trim(),
      destinationArea: _destAreaController.text.trim().isNotEmpty ? _destAreaController.text.trim() : null,
      destinationLatitude: _destLat,
      destinationLongitude: _destLon,
      travelDate: _travelDate,
      travelTime: formattedTime,
      isTimeFlexible: _isTimeFlexible,
      totalSeats: _seats,
      availableSeats: _seats,
      contributionAmount: contribution,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      status: 'open',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    final created = await ref.read(createRideNotifierProvider.notifier).submitRide(ride);
    if (created != null && mounted) {
      final s = ref.read(stringsProvider);
      AppSnackBar.show(
        context,
        message: s.isHindi ? 'सवारी सफलतापूर्वक प्रकाशित की गई!' : 'Ride published successfully!',
        isSuccess: true,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final createRideState = ref.watch(createRideNotifierProvider);
    final isLoading = createRideState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.createRidePageTitle),
        actions: const [
          LanguageSwitcherButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 90.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category Selection
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            label: Center(child: Text(s.isHindi ? 'निजी वाहन (कार/बाइक)' : 'Personal Vehicle (Car/Bike)')),
                            selected: _rideCategory == 'private_vehicle',
                            selectedColor: AppTheme.primaryGreen,
                            labelStyle: TextStyle(
                              color: _rideCategory == 'private_vehicle' ? Colors.white : AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _rideCategory = 'private_vehicle');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            label: Center(child: Text(s.isHindi ? 'सामान्य यात्रा' : 'General Travel')),
                            selected: _rideCategory == 'general_travel',
                            selectedColor: AppTheme.primaryGreen,
                            labelStyle: TextStyle(
                              color: _rideCategory == 'general_travel' ? Colors.white : AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _rideCategory = 'general_travel');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vehicle type selector if private vehicle
                  if (_rideCategory == 'private_vehicle') ...[
                    Text(
                      s.vehicleTypeLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _onVehicleChanged('car'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _vehicleType == 'car'
                                    ? AppTheme.primaryGreen.withOpacity(0.12)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _vehicleType == 'car'
                                      ? AppTheme.primaryGreen
                                      : const Color(0xFFCBD5E1),
                                  width: _vehicleType == 'car' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.directions_car_rounded,
                                    color: _vehicleType == 'car' ? AppTheme.primaryGreen : AppTheme.textMuted,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.vehicleCarLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _vehicleType == 'car' ? AppTheme.primaryGreen : AppTheme.textDark,
                                    ),
                                  ),
                                  Text(s.isHindi ? '1-8 सीटें' : '1-8 seats', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _onVehicleChanged('bike'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _vehicleType == 'bike'
                                    ? AppTheme.primaryGreen.withOpacity(0.12)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _vehicleType == 'bike'
                                      ? AppTheme.primaryGreen
                                      : const Color(0xFFCBD5E1),
                                  width: _vehicleType == 'bike' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.two_wheeler_rounded,
                                    color: _vehicleType == 'bike' ? AppTheme.primaryGreen : AppTheme.textMuted,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.vehicleBikeLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _vehicleType == 'bike' ? AppTheme.primaryGreen : AppTheme.textDark,
                                    ),
                                  ),
                                  Text(s.isHindi ? '1-3 सीटें' : '1-3 seats', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _onVehicleChanged('other'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _vehicleType == 'other'
                                    ? AppTheme.primaryGreen.withOpacity(0.12)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _vehicleType == 'other'
                                      ? AppTheme.primaryGreen
                                      : const Color(0xFFCBD5E1),
                                  width: _vehicleType == 'other' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.airport_shuttle_rounded,
                                    color: _vehicleType == 'other' ? AppTheme.primaryGreen : AppTheme.textMuted,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.vehicleOtherLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _vehicleType == 'other' ? AppTheme.primaryGreen : AppTheme.textDark,
                                    ),
                                  ),
                                  Text(s.isHindi ? '1-12 सीटें' : '1-12 seats', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Origin City & Area
                  LocationAutocompleteField(
                    controller: _originCityController,
                    labelText: s.originCityLabel,
                    hintText: s.originCityHint,
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryGreen),
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
                    prefixIcon: const Icon(Icons.flag_outlined, color: AppTheme.accentAmber),
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
                  const SizedBox(height: 16),

                  // Date and Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_month_rounded, size: 20),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(_travelDate),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time_rounded, size: 20),
                          label: Text(
                            _travelTime != null ? _travelTime!.format(context) : s.travelTimeLabel,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Flexible time switch
                  SwitchListTile(
                    title: Text(s.flexibleTimeLabel, style: const TextStyle(fontSize: 15)),
                    value: _isTimeFlexible,
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _isTimeFlexible = val),
                  ),
                  const SizedBox(height: 12),

                  // Seats Counter with Vehicle Capping
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.totalSeatsLabel,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.isHindi
                                        ? (_rideCategory == 'general_travel'
                                            ? 'अधिकतम 8 सह-यात्री'
                                            : (_vehicleType == 'bike'
                                                ? '🏍️ बाइक: डिफ़ॉल्ट 1 सीट (1-3 उपलब्ध)'
                                                : (_vehicleType == 'car'
                                                    ? '🚗 कार: डिफ़ॉल्ट 4 सीटें (1-8 उपलब्ध)'
                                                    : '🚐 अन्य: डिफ़ॉल्ट 6 सीटें (1-12 उपलब्ध)')))
                                        : (_rideCategory == 'general_travel'
                                            ? 'Max 8 co-travelers'
                                            : (_vehicleType == 'bike'
                                                ? '🏍️ Bike: Default 1 seat (1-3 available)'
                                                : (_vehicleType == 'car'
                                                    ? '🚗 Car: Default 4 seats (1-8 available)'
                                                    : '🚐 Other: Default 6 seats (1-12 available)'))),
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryGreen, size: 28),
                                  onPressed: _seats > 1 ? () => setState(() => _seats--) : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: Text(
                                    '$_seats',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen, size: 28),
                                  onPressed: _seats < _maxSeatsForVehicle ? () => setState(() => _seats++) : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Optional Contribution Amount
                  TextFormField(
                    controller: _contributionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: s.contributionAmountLabel,
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: s.notesLabel,
                      hintText: s.notesHint,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(s.publishRideButtonText, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
