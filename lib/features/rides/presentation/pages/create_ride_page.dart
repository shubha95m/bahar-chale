import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
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
  int _seats = 3;

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

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया पहले साइन इन करें।')),
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
      destinationCity: _destCityController.text.trim(),
      destinationArea: _destAreaController.text.trim().isNotEmpty ? _destAreaController.text.trim() : null,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('सवारी सफलतापूर्वक प्रकाशित की गई!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final createRideState = ref.watch(createRideNotifierProvider);
    final isLoading = createRideState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('सवारी प्रकाशित करें'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                            label: const Center(child: Text('निजी वाहन (कार/बाइक)')),
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
                            label: const Center(child: Text('सामान्य यात्रा')),
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

                  // Vehicle type dropdown if private vehicle
                  if (_rideCategory == 'private_vehicle') ...[
                    DropdownButtonFormField<String>(
                      value: _vehicleType,
                      decoration: const InputDecoration(labelText: AppStrings.vehicleType),
                      items: const [
                        DropdownMenuItem(value: 'car', child: Text(AppStrings.vehicleCar)),
                        DropdownMenuItem(value: 'bike', child: Text(AppStrings.vehicleBike)),
                        DropdownMenuItem(value: 'other', child: Text(AppStrings.vehicleOther)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _vehicleType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Origin City & Area
                  TextFormField(
                    controller: _originCityController,
                    decoration: const InputDecoration(
                      labelText: '${AppStrings.originCity} *',
                      prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.primaryGreen),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'कृपया प्रस्थान शहर दर्ज करें' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _originAreaController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.originArea,
                      prefixIcon: Icon(Icons.place_outlined, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Destination City & Area
                  TextFormField(
                    controller: _destCityController,
                    decoration: const InputDecoration(
                      labelText: '${AppStrings.destinationCity} *',
                      prefixIcon: Icon(Icons.flag_outlined, color: AppTheme.accentAmber),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'कृपया गंतव्य शहर दर्ज करें' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _destAreaController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.destinationArea,
                      prefixIcon: Icon(Icons.place_outlined, color: AppTheme.textMuted),
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
                            _travelTime != null ? _travelTime!.format(context) : 'समय (वैकल्पिक)',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Flexible time switch
                  SwitchListTile(
                    title: const Text(AppStrings.flexibleTime, style: TextStyle(fontSize: 15)),
                    value: _isTimeFlexible,
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _isTimeFlexible = val),
                  ),
                  const SizedBox(height: 12),

                  // Seats Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.totalSeats,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryGreen),
                            onPressed: _seats > 1 ? () => setState(() => _seats--) : null,
                          ),
                          Text(
                            '$_seats',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen),
                            onPressed: _seats < 8 ? () => setState(() => _seats++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Optional Contribution Amount
                  TextFormField(
                    controller: _contributionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.contributionAmount,
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: AppStrings.notes,
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
                        : const Text('सवारी साझा करें', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
