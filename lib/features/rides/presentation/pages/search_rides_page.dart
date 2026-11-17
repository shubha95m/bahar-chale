import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../domain/entities/ride.dart';
import '../providers/rides_provider.dart';

class SearchRidesPage extends ConsumerStatefulWidget {
  const SearchRidesPage({super.key});

  @override
  ConsumerState<SearchRidesPage> createState() => _SearchRidesPageState();
}

class _SearchRidesPageState extends ConsumerState<SearchRidesPage> {
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedCategory;
  SearchParams? _currentParams;

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _search() {
    if (_originController.text.trim().isEmpty || _destController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया प्रस्थान और गंतव्य दोनों शहर दर्ज करें।')),
      );
      return;
    }

    setState(() {
      _currentParams = SearchParams(
        originCity: _originController.text.trim(),
        destinationCity: _destController.text.trim(),
        travelDate: _selectedDate,
        rideCategory: _selectedCategory,
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = _currentParams != null
        ? ref.watch(searchRidesProvider(_currentParams!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('सवारी खोजें'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _originController,
                          decoration: InputDecoration(
                            hintText: AppStrings.originCity,
                            prefixIcon: const Icon(Icons.my_location_rounded, size: 20, color: AppTheme.primaryGreen),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _destController,
                          decoration: InputDecoration(
                            hintText: AppStrings.destinationCity,
                            prefixIcon: const Icon(Icons.location_on_rounded, size: 20, color: AppTheme.accentAmber),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(42),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _search,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(110, 42),
                        ),
                        child: const Text('सवारी खोजें', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Results or Placeholder
            Expanded(
              child: _currentParams == null
                  ? _buildEmptyState(
                      icon: Icons.travel_explore_rounded,
                      title: 'सवारी खोजने के लिए विवरण दर्ज करें',
                      subtitle: 'प्रस्थान और गंतव्य शहर चुनकर खोज बटन दबाएं।',
                    )
                  : searchAsync!.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'सवारी लोड करने में त्रुटि: ${err.toString()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      data: (rides) {
                        if (rides.isEmpty) {
                          return _buildEmptyState(
                            icon: Icons.sentiment_dissatisfied_rounded,
                            title: 'कोई सवारी उपलब्ध नहीं है',
                            subtitle: 'इस तारीख को कोई मेल खाती यात्रा नहीं मिली। आप खुद भी सवारी प्रकाशित कर सकते हैं!',
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: rides.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final ride = rides[index];
                            return _buildRideCard(context, ride);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, Ride ride) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/ride/${ride.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Provider & Badge
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                    child: Text(
                      ride.ownerName?.isNotEmpty == true ? ride.ownerName![0].toUpperCase() : 'य',
                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.ownerName ?? 'सवारी प्रदाता',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textDark),
                        ),
                        Text(
                          ride.rideCategory == 'private_vehicle'
                              ? 'निजी वाहन (${ride.vehicleType == 'bike' ? 'बाइक' : 'कार'})'
                              : 'सामान्य यात्रा समन्वय',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (ride.contributionAmount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${ride.contributionAmount!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.accentAmber,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 24, thickness: 0.8),

              // Route Display
              Row(
                children: [
                  const Icon(Icons.route_rounded, color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ride.routeDisplay,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date, Time and Seats Info
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    ride.travelTime != null ? ride.travelTime! : 'समय लचीला',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${ride.availableSeats} सीट उपलब्ध',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
