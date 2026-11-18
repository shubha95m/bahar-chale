import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/app_bottom_bar.dart';
import '../../../../core/widgets/language_switcher_button.dart';
import '../../../../core/widgets/location_autocomplete_field.dart';
import '../../../../core/widgets/passenger_request_card_widget.dart';
import '../../../../core/widgets/ride_card_widget.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../notifications/presentation/widgets/notifications_sheet.dart';
import '../../../requests/presentation/providers/passenger_requests_provider.dart';
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
  int _feedType = 0; // 0 = Driver Rides, 1 = Passenger Requests
  bool _isAdvancedOpen = false;

  final List<Map<String, String>> _popularRoutes = [
    {'origin': 'Pune', 'dest': 'Mumbai', 'labelHi': 'पुणे ➔ मुंबई', 'labelEn': 'Pune ➔ Mumbai'},
    {'origin': 'Delhi', 'dest': 'Jaipur', 'labelHi': 'दिल्ली ➔ जयपुर', 'labelEn': 'Delhi ➔ Jaipur'},
    {'origin': 'Bengaluru', 'dest': 'Mysuru', 'labelHi': 'बेंगलुरु ➔ मैसूर', 'labelEn': 'Bengaluru ➔ Mysuru'},
    {'origin': 'Chandigarh', 'dest': 'Delhi', 'labelHi': 'चंडीगढ़ ➔ दिल्ली', 'labelEn': 'Chandigarh ➔ Delhi'},
    {'origin': 'Ahmedabad', 'dest': 'Vadodara', 'labelHi': 'अहमदाबाद ➔ वडोदरा', 'labelEn': 'Ahmedabad ➔ Vadodara'},
    {'origin': 'Lucknow', 'dest': 'Kanpur', 'labelHi': 'लखनऊ ➔ कानपुर', 'labelEn': 'Lucknow ➔ Kanpur'},
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
    final passengerFilter = BrowsePassengerFilter(
      query: _searchQueryController.text.trim().isNotEmpty ? _searchQueryController.text.trim() : null,
      vehicleType: _selectedVehicle != 'all' ? _selectedVehicle : null,
    );

    final ridesAsync = ref.watch(allAvailableRidesProvider(filter));
    final passengerReqsAsync = ref.watch(allOpenPassengerRequestsProvider(passengerFilter));
    final unreadMessagesCount = ref.watch(unreadConversationsCountProvider).value ?? 0;
    final unreadNotificationsCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

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
            tooltip: s.notificationsText,
            icon: Badge.count(
              count: unreadNotificationsCount,
              isLabelVisible: unreadNotificationsCount > 0,
              backgroundColor: Colors.red.shade700,
              child: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryGreen),
            ),
            onPressed: () => NotificationsSheet.show(context),
          ),
          IconButton(
            tooltip: s.navMessagesText,
            icon: Badge.count(
              count: unreadMessagesCount,
              isLabelVisible: unreadMessagesCount > 0,
              backgroundColor: Colors.red.shade700,
              child: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryGreen),
            ),
            onPressed: () async {
              await context.push('/conversations');
              ref.invalidate(unreadConversationsCountProvider);
            },
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
                            label: Text(
                              s.isHindi ? (route['labelHi'] ?? '') : (route['labelEn'] ?? ''),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: const Color(0xFFF1F5F9),
                            onPressed: () => _applyPopularRoute(route['origin']!, route['dest']!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Dual Marketplace Feed Segmented Switcher
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<int>(
                          segments: [
                            ButtonSegment(
                              value: 0,
                              icon: const Icon(Icons.directions_car_rounded, size: 16),
                              label: Text(
                                s.isHindi ? 'सवारियां (Driver Rides)' : 'Driver Rides',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ButtonSegment(
                              value: 1,
                              icon: const Icon(Icons.people_alt_rounded, size: 16),
                              label: Text(
                                s.isHindi ? 'सहयात्री की जरूरतें' : 'Passenger Requests',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          selected: {_feedType},
                          onSelectionChanged: (set) => setState(() => _feedType = set.first),
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: _feedType == 0 ? AppTheme.primaryGreen : AppTheme.accentAmber,
                            selectedForegroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Collapsible Advanced Filter (Origin + Destination Autocomplete + Date)
                  if (_isAdvancedOpen) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: LocationAutocompleteField(
                            controller: _originController,
                            labelText: s.originCityLabel,
                            hintText: s.isHindi ? 'उदा. Pune' : 'e.g. Pune',
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
                            labelText: s.destinationCityLabel,
                            hintText: s.isHindi ? 'उदा. Mumbai' : 'e.g. Mumbai',
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
                                  : (s.isHindi ? 'यात्रा की तारीख चुनें' : 'Select travel date'),
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

            // Live List Feed (Driver Rides vs Passenger Requests)
            Expanded(
              child: _feedType == 0
                  // FEED 0: Driver Rides
                  ? ridesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh_rounded, color: AppTheme.textMuted, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                s.isHindi ? 'सवारियां लोड करने में असमर्थ' : 'Unable to load rides',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.isHindi ? 'कृपया इंटरनेट जांचें या पुनः प्रयास करें।' : 'Please check your connection and retry.',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.refresh(allAvailableRidesProvider(filter)),
                                child: Text(s.isHindi ? 'पुनः प्रयास करें' : 'Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (rides) {
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
                            title: s.noRidesFoundTitle,
                            subtitle: s.noRidesFoundSubtitle,
                            actionLabel: s.actionGiveRideText,
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
                              return RideCardWidget(ride: ride);
                            },
                          ),
                        );
                      },
                    )
                  // FEED 1: Passenger Requests
                  : passengerReqsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh_rounded, color: AppTheme.textMuted, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                s.isHindi ? 'यात्रा अनुरोध लोड करने में असमर्थ' : 'Unable to load travel requests',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.isHindi ? 'कृपया इंटरनेट जांचें या पुनः प्रयास करें।' : 'Please check your connection and retry.',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.refresh(allOpenPassengerRequestsProvider(passengerFilter)),
                                child: Text(s.isHindi ? 'पुनः प्रयास करें' : 'Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (passengerReqs) {
                        var displayedReqs = passengerReqs;
                        if (_selectedDate != null) {
                          final dateKey = _selectedDate!.toIso8601String().split('T').first;
                          displayedReqs = displayedReqs.where((r) {
                            return r.travelDate.toIso8601String().split('T').first == dateKey;
                          }).toList();
                        }

                        if (displayedReqs.isEmpty) {
                          return _buildEmptyState(
                            icon: Icons.person_pin_circle_outlined,
                            title: s.isHindi ? 'कोई यात्रा अनुरोध नहीं मिला' : 'No Passenger Requests Found',
                            subtitle: s.isHindi
                                ? 'अभी इस रूट के लिए किसी सहयात्री ने अनुरोध पोस्ट नहीं किया है। क्या आप अपनी आवश्यकता पोस्ट करना चाहेंगे?'
                                : 'No co-travelers posted for this route yet. Would you like to post your need?',
                            actionLabel: s.isHindi ? 'सवारी की जरूरत पोस्ट करें' : 'Post Ride Request',
                            onAction: () => context.push('/create-passenger-request'),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async => ref.refresh(allOpenPassengerRequestsProvider(passengerFilter)),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayedReqs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final req = displayedReqs[index];
                              return PassengerRequestCardWidget(request: req);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_feedType == 0) {
            context.push('/create-ride');
          } else {
            context.push('/create-passenger-request');
          }
        },
        backgroundColor: _feedType == 0 ? AppTheme.primaryGreen : AppTheme.accentAmber,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _feedType == 0
              ? (s.isHindi ? 'सवारी प्रस्तुत करें' : 'Offer Ride')
              : (s.isHindi ? 'जरूरत पोस्ट करें' : 'Post Request'),
          style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
    ),
  );
  }
}
