import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_theme.dart';
import '../../features/rides/domain/entities/ride.dart';
import '../localization/app_strings.dart';
import '../utilities/map_launcher.dart';

class RideCardWidget extends ConsumerWidget {
  final Ride ride;
  final bool isOwner;
  final VoidCallback? onTap;

  const RideCardWidget({
    super.key,
    required this.ride,
    this.isOwner = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final hasSeats = ride.availableSeats > 0;
    final isLastSeat = ride.availableSeats == 1;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Profile Header & Available Seats Badge
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                  child: Text(
                    ride.ownerName?.isNotEmpty == true ? ride.ownerName![0].toUpperCase() : 'Y',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              ride.ownerName ?? (s.isHindi ? 'चालक (Driver)' : 'Driver'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 11, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  s.isHindi ? 'सत्यापित' : 'Verified',
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.brown),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            ride.vehicleType == 'bike' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                            size: 13,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ride.vehicleLabel,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Remaining Seats Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: !hasSeats
                        ? Colors.red.withOpacity(0.1)
                        : (isLastSeat ? Colors.amber.withOpacity(0.15) : AppTheme.primaryGreen.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: !hasSeats
                          ? Colors.red.withOpacity(0.3)
                          : (isLastSeat ? Colors.amber.shade400 : AppTheme.primaryGreen.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    !hasSeats
                        ? (s.isHindi ? 'फुल (Full)' : 'Full')
                        : '${ride.availableSeats} / ${ride.totalSeats} ${s.isHindi ? "सीटें" : "seats"}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: !hasSeats
                          ? Colors.red.shade700
                          : (isLastSeat ? Colors.brown.shade800 : AppTheme.primaryGreen),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20, thickness: 0.8),

            // Route & Timings Box
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
                      const Icon(Icons.route_rounded, color: AppTheme.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride.routeDisplay,
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
                        '${DateFormat('dd MMM yyyy').format(ride.travelDate)} • ${ride.travelTime ?? (s.isHindi ? 'लचीला समय' : 'Flexible')}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (ride.notes != null && ride.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '${s.isHindi ? "टिप्पणी" : "Note"}: ${ride.notes}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Actions Row: Free Google Maps Deep Link & View Details / Join
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
                      origin: ride.originCity,
                      destination: ride.destinationCity,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(isOwner ? Icons.group_outlined : Icons.handshake_outlined, size: 16),
                    label: Text(
                      isOwner
                          ? (s.isHindi ? 'यात्री व विवरण' : 'View Passengers')
                          : s.viewDetailsAndRequest,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    onPressed: onTap ?? () => context.push('/ride/${ride.id}'),
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
