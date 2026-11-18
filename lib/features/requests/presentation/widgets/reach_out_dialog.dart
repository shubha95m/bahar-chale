import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/passenger_request.dart';
import '../providers/passenger_requests_provider.dart';

class ReachOutDialog extends ConsumerStatefulWidget {
  final PassengerRequest request;

  const ReachOutDialog({super.key, required this.request});

  static Future<void> show(BuildContext context, PassengerRequest request) async {
    await showDialog(
      context: context,
      builder: (ctx) => ReachOutDialog(request: request),
    );
  }

  @override
  ConsumerState<ReachOutDialog> createState() => _ReachOutDialogState();
}

class _ReachOutDialogState extends ConsumerState<ReachOutDialog> {
  String _vehicleType = 'car';
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 30);
  int _totalSeats = 4;
  late final TextEditingController _messageController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final passengerName = widget.request.requesterName ?? 'साथी';
    final route = '${widget.request.originCity} से ${widget.request.destinationCity}';
    _messageController = TextEditingController(
      text: 'नमस्ते $passengerName! मैं भी $route के लिए जा रहा हूँ। क्या आप साथ चलना चाहेंगे?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onVehicleChanged(String type) {
    setState(() {
      _vehicleType = type;
      if (type == 'bike') {
        _totalSeats = 1;
      } else {
        _totalSeats = 4;
      }
    });
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.pop();
      context.push('/login');
      return;
    }

    if (user.id == widget.request.requesterId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('आप अपने ही अनुरोध पर प्रस्ताव नहीं भेज सकते।')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final departureTimeStr = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    final rideRequestId = await ref.read(passengerRequestActionNotifierProvider.notifier).reachOut(
      passengerRequest: widget.request,
      driverId: user.id,
      vehicleType: _vehicleType,
      departureTime: departureTimeStr,
      totalSeats: _totalSeats,
      initialMessage: _messageController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();

      if (rideRequestId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('प्रस्ताव व संदेश भेज दिया गया है! बातचीत खुल रही है...'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        context.push('/chat/$rideRequestId');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('प्रस्ताव भेजने में त्रुटि। कृपया पुनः प्रयास करें।'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final req = widget.request;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handshake_rounded, color: AppTheme.primaryGreen, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.isHindi ? 'सवारी की पेशकश करें' : 'Offer Ride',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.routeDisplay,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(req.travelDate)} • ${req.seatsNeeded} सीट की आवश्यकता',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle choice
            Text(
              s.isHindi ? 'आपका वाहन:' : 'Your Vehicle:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.directions_car_rounded, size: 16),
                    label: Text(s.carText),
                    selected: _vehicleType == 'car',
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: _vehicleType == 'car' ? Colors.white : AppTheme.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) => _onVehicleChanged('car'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.two_wheeler_rounded, size: 16),
                    label: Text(s.bikeText),
                    selected: _vehicleType == 'bike',
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: _vehicleType == 'bike' ? Colors.white : AppTheme.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) => _onVehicleChanged('bike'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Time Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.isHindi ? 'प्रस्थान समय:' : 'Departure Time:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                  icon: const Icon(Icons.access_time_rounded, size: 16),
                  label: Text(_time.format(context), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Message for passenger
            Text(
              s.isHindi ? 'यात्री को प्रारंभिक संदेश:' : 'Initial message for traveler:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _messageController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'उदा. मैं 8:30 बजे निकलूंगा, आएं साथ चलें',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancelText),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(s.isHindi ? 'प्रस्ताव व संदेश भेजें' : 'Send Offer & Chat'),
        ),
      ],
    );
  }
}
