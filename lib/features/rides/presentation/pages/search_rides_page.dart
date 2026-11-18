import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utilities/map_launcher.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../../core/widgets/location_autocomplete_field.dart';
import '../../domain/entities/ride.dart';
import '../providers/rides_provider.dart';

class SearchRidesPage extends ConsumerStatefulWidget {
  const SearchRidesPage({super.key});

  @override
  ConsumerState<SearchRidesPage> createState() => _SearchRidesPageState();
}

class _SearchRidesPageState extends ConsumerState<SearchRidesPage> {
  final _searchQueryController = TextEditingController();
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  DateTime? _selectedDate;

  String _selectedVehicle = 'all'; // 'all' | 'car' | 'bike'
  bool _isAdvancedOpen = false;

  final List<Map<String, String>> _popularRoutes = [
    {'origin': 'Pune', 'dest': 'Mumbai', 'label': 'पुणे ➔ मुंबई'},
    {'origin': 'Delhi', 'dest': 'Jaipur', 'label': 'दिल्ली ➔ जयपुर'},
    {'origin': 'Bengaluru', 'dest': 'Mysuru', 'label': 'बेंगलुरु ➔ मैसूर'},
    {'origin': 'Chandigarh', 'dest': 'Delhi', 'label': 'चंडीगढ़ ➔ दिल्ली'},
    {'origin': 'Ahmedabad', 'dest': 'Vadodara', 'label': 'अहमदाबाद ➔ वडोदरा'},
    {'origin': 'Lucknow', 'dest': 'Kanpur', 'label': 'लखनऊ ➔ कानपुर'},
  ];

  @override
  void dispose() {
    _searchQueryController.dispose();
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _applyPopularRoute(String origin, String dest) {
    setState(() {
      _searchQueryController.text = '$origin $dest';
      _originController.text = origin;
      _destController.text = dest;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQueryController.clear();
      _originController.clear();
      _destController.clear();
      _selectedDate = null;
      _selectedVehicle = 'all';
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final filter = BrowseRidesFilter(
      query: _searchQueryController.text.trim().isNotEmpty ? _searchQueryController.text.trim() : null,
      vehicleType: _selectedVehicle != 'all' ? _selectedVehicle : null,
    );

    final ridesAsync = ref.watch(allAvailableRidesProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.searchPageTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(s.searchPageSubtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          const LanguageSwitcherButton(),
          IconButton(
            tooltip: s.navMessagesText,
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryGreen),
            onPressed: () => context.push('/conversations'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Search & Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fast Universal Search Bar
                  TextField(
                    controller: _searchQueryController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: s.searchBarHint,
                      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen),
                      suffixIcon: _searchQueryController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchQueryController.clear();
                                setState(() {});
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                _isAdvancedOpen ? Icons.tune_rounded : Icons.filter_list_rounded,
                                color: _isAdvancedOpen ? AppTheme.primaryGreen : AppTheme.textMuted,
                              ),
                              tooltip: s.isHindi ? 'विस्तृत फिल्टर' : 'Filters',
                              onPressed: () => setState(() => _isAdvancedOpen = !_isAdvancedOpen),
                            ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  // Quick vehicle type selector
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildVehicleFilterChip('all', s.allVehiclesText, Icons.directions_car_filled_outlined),
                      const SizedBox(width: 8),
                      _buildVehicleFilterChip('car', s.carText, Icons.directions_car_rounded),
                      const SizedBox(width: 8),
                      _buildVehicleFilterChip('bike', s.bikeText, Icons.two_wheeler_rounded),
                      const Spacer(),
                      if (_searchQueryController.text.isNotEmpty || _selectedVehicle != 'all' || _selectedDate != null)
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text(s.clearFilterText, style: const TextStyle(fontSize: 12, color: Colors.red)),
                        ),
                    ],
                  ),

                  // Popular Route Chips
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _popularRoutes.map((route) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            avatar: const Icon(Icons.trending_up_rounded, size: 14, color: AppTheme.primaryGreen),
                            label: Text(route['label']!, style: const TextStyle(fontSize: 12)),
                            backgroundColor: const Color(0xFFF1F5F9),
                            onPressed: () => _applyPopularRoute(route['origin']!, route['dest']!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Collapsible Advanced Filter (Origin + Destination Autocomplete + Date)
                  if (_isAdvancedOpen) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: LocationAutocompleteField(
                            controller: _originController,
                            labelText: 'प्रस्थान शहर (From)',
                            hintText: 'उदा. Pune',
                            prefixIcon: const Icon(Icons.my_location_rounded, size: 18, color: AppTheme.primaryGreen),
                            onSelected: (val) {
                              _searchQueryController.text = '$val ${_destController.text}'.trim();
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LocationAutocompleteField(
                            controller: _destController,
                            labelText: 'गंतव्य शहर (To)',
                            hintText: 'उदा. Mumbai',
                            prefixIcon: const Icon(Icons.location_on_rounded, size: 18, color: AppTheme.accentAmber),
                            onSelected: (val) {
                              _searchQueryController.text = '${_originController.text} $val'.trim();
                              setState(() {});
                            },
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
                              _selectedDate != null
                                  ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                                  : 'यात्रा की तारीख चुनें',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => setState(() => _selectedDate = null),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Live Rides List Feed
            Expanded(
              child: ridesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                        const SizedBox(height: 12),
                        Text('सवारियां लोड करने में त्रुटि: $err', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(allAvailableRidesProvider(filter)),
                          child: const Text('पुनः प्रयास करें'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (rides) {
                  // Apply in-memory client filtering for date if set
                  var displayedRides = rides;
                  if (_selectedDate != null) {
                    final dateKey = _selectedDate!.toIso8601String().split('T').first;
                    displayedRides = displayedRides.where((r) {
                      return r.travelDate.toIso8601String().split('T').first == dateKey;
                    }).toList();
                  }

                  if (displayedRides.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.travel_explore_rounded,
                      title: 'कोई सवारी उपलब्ध नहीं है',
                      subtitle: 'आपके चुने गए स्थान या तारीख के लिए अभी कोई सक्रिय राइड नहीं मिली। क्या आप खुद सवारी प्रस्तुत करना चाहेंगे?',
                      actionLabel: 'सवारी प्रस्तुत करें (Offer Ride)',
                      onAction: () => context.push('/create-ride'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(allAvailableRidesProvider(filter)),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayedRides.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final ride = displayedRides[index];
                        return _buildRideCard(context, ride);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedVehicle == value;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppTheme.textDark,
      ),
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : AppTheme.textDark,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedVehicle = value);
      },
    );
  }

  Widget _buildRideCard(BuildContext context, Ride ride) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                  child: Text(
                    ride.ownerName?.isNotEmpty == true ? ride.ownerName![0].toUpperCase() : 'Y',
                    style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16),
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
                              ride.ownerName ?? 'सवारी प्रदाता',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                                SizedBox(width: 2),
                                Text('सत्यापित', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
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
                            size: 14,
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
                // Seats Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ride.availableSeats > 0
                        ? AppTheme.primaryGreen.withOpacity(0.12)
                        : Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ride.availableSeats} / ${ride.totalSeats} सीटें',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ride.availableSeats > 0 ? AppTheme.primaryGreen : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20, thickness: 0.8),

            // Route Section
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
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
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.event_outlined, size: 15, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(ride.travelDate)} • ${ride.travelTime ?? 'लचीला समय'}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (ride.notes != null && ride.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'टिप्पणी: ${ride.notes}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.handshake_outlined, size: 16),
                    label: const Text('विवरण व अनुरोध', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () => context.push('/ride/${ride.id}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
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
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 44),
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
