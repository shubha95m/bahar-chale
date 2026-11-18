import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_theme.dart';
import '../../features/requests/domain/entities/passenger_request.dart';
import '../../features/requests/presentation/widgets/reach_out_dialog.dart';
import '../localization/app_strings.dart';
import '../utilities/map_launcher.dart';

class PassengerRequestCardWidget extends ConsumerWidget {
  final PassengerRequest request;
  final bool isOwner;
  final VoidCallback? onCancel;

  const PassengerRequestCardWidget({
    super.key,
    required this.request,
    this.isOwner = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.accentAmber.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Requester Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.accentAmber.withOpacity(0.15),
                  child: Text(
                    request.requesterName?.isNotEmpty == true ? request.requesterName![0].toUpperCase() : 'Y',
                    style: const TextStyle(
                      color: AppTheme.accentAmber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName ?? (s.isHindi ? 'सहयात्री (Passenger)' : 'Co-traveler'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request.seatsNeeded} ${s.isHindi ? "सीट की आवश्यकता" : (request.seatsNeeded == 1 ? "seat needed" : "seats needed")} • ${request.localizedVehicleLabel(isHindi: s.isHindi)}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3)),
                  ),
                  child: Text(
                    s.isHindi ? 'सवारी चाहिए' : 'Needs Ride',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentAmber,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20, thickness: 0.8),

            // Route Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEDF2F7)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin_circle_rounded, color: AppTheme.accentAmber, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.routeDisplay,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.event_outlined, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(request.travelDate)} • ${request.travelTime ?? (s.isHindi ? 'लचीला समय' : 'Flexible')}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '${s.isHindi ? "टिप्पणी" : "Note"}: ${request.notes}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Actions Row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Google Maps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => MapLauncher.openDirections(
                      origin: request.originCity,
                      destination: request.destinationCity,
                      originArea: request.originArea,
                      destinationArea: request.destinationArea,
                      originLat: request.originLatitude,
                      originLon: request.originLongitude,
                      destinationLat: request.destinationLatitude,
                      destinationLon: request.destinationLongitude,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: isOwner
                      ? OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: Text(s.isHindi ? 'रद्द करें' : 'Cancel Request', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          onPressed: onCancel,
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentAmber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.handshake_outlined, size: 16),
                          label: Text(
                            s.isHindi ? 'सवारी प्रस्तुत करें (Offer)' : 'Offer Ride',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => ReachOutDialog.show(context, request),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
