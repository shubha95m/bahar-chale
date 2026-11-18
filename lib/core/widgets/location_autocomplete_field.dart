import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../utilities/map_launcher.dart';

class IndianCity {
  final String englishName;
  final String hindiName;
  final String state;

  const IndianCity({
    required this.englishName,
    required this.hindiName,
    required this.state,
  });

  String get displayName => '$englishName ($hindiName)';
}

/// Curated dictionary of top Indian cities across states for instant 0ms typo-free autocomplete
const List<IndianCity> kTopIndianCities = [
  // Maharashtra
  IndianCity(englishName: 'Pune', hindiName: 'पुणे', state: 'Maharashtra'),
  IndianCity(englishName: 'Mumbai', hindiName: 'मुंबई', state: 'Maharashtra'),
  IndianCity(englishName: 'Thane', hindiName: 'ठाणे', state: 'Maharashtra'),
  IndianCity(englishName: 'Navi Mumbai', hindiName: 'नवी मुंबई', state: 'Maharashtra'),
  IndianCity(englishName: 'Nashik', hindiName: 'नासिक', state: 'Maharashtra'),
  IndianCity(englishName: 'Nagpur', hindiName: 'नागपुर', state: 'Maharashtra'),
  IndianCity(englishName: 'Aurangabad', hindiName: 'छत्रपति संभाजीनगर', state: 'Maharashtra'),
  IndianCity(englishName: 'Kolhapur', hindiName: 'कोल्हापुर', state: 'Maharashtra'),
  IndianCity(englishName: 'Solapur', hindiName: 'सोलापुर', state: 'Maharashtra'),
  IndianCity(englishName: 'Satara', hindiName: 'सातारा', state: 'Maharashtra'),

  // NCR & North
  IndianCity(englishName: 'Delhi', hindiName: 'दिल्ली', state: 'Delhi NCR'),
  IndianCity(englishName: 'New Delhi', hindiName: 'नई दिल्ली', state: 'Delhi NCR'),
  IndianCity(englishName: 'Gurugram', hindiName: 'गुरुग्राम', state: 'Haryana'),
  IndianCity(englishName: 'Noida', hindiName: 'नोएडा', state: 'Uttar Pradesh'),
  IndianCity(englishName: 'Greater Noida', hindiName: 'ग्रेटर नोएडा', state: 'Uttar Pradesh'),
  IndianCity(englishName: 'Ghaziabad', hindiName: 'गाजियाबाद', state: 'Uttar Pradesh'),
  IndianCity(englishName: 'Faridabad', hindiName: 'फरीदाबाद', state: 'Haryana'),
  IndianCity(englishName: 'Chandigarh', hindiName: 'चंडीगढ़', state: 'Chandigarh'),
  IndianCity(englishName: 'Mohali', hindiName: 'मोहाली', state: 'Punjab'),
  IndianCity(englishName: 'Panchkula', hindiName: 'पंचकूला', state: 'Haryana'),
  IndianCity(englishName: 'Ludhiana', hindiName: 'लुधियाना', state: 'Punjab'),
  IndianCity(englishName: 'Amritsar', hindiName: 'अमृतसर', state: 'Punjab'),
  IndianCity(englishName: 'Jalandhar', hindiName: 'जालंधर', state: 'Punjab'),
  IndianCity(englishName: 'Dehradun', hindiName: 'देहरादून', state: 'Uttarakhand'),
  IndianCity(englishName: 'Haridwar', hindiName: 'हरिद्वार', state: 'Uttarakhand'),
  IndianCity(englishName: 'Rishikesh', hindiName: 'ऋषिकेश', state: 'Uttarakhand'),
  IndianCity(englishName: 'Shimla', hindiName: 'शिमला', state: 'Himachal Pradesh'),

  // Rajasthan
  IndianCity(englishName: 'Jaipur', hindiName: 'जयपुर', state: 'Rajasthan'),
  IndianCity(englishName: 'Udaipur', hindiName: 'उदयपुर', state: 'Rajasthan'),
  IndianCity(englishName: 'Jodhpur', hindiName: 'जोधपुर', state: 'Rajasthan'),
  IndianCity(englishName: 'Kota', hindiName: 'कोटा', state: 'Rajasthan'),
  IndianCity(englishName: 'Ajmer', hindiName: 'अजमेर', state: 'Rajasthan'),
  IndianCity(englishName: 'Bikaner', hindiName: 'बीकानेर', state: 'Rajasthan'),

  // Gujarat
  IndianCity(englishName: 'Ahmedabad', hindiName: 'अहमदाबाद', state: 'Gujarat'),
  IndianCity(englishName: 'Surat', hindiName: 'सूरत', state: 'Gujarat'),
  IndianCity(englishName: 'Vadodara', hindiName: 'वडोदरा', state: 'Gujarat'),
  IndianCity(englishName: 'Rajkot', hindiName: 'राजकोट', state: 'Gujarat'),
  IndianCity(englishName: 'Gandhinagar', hindiName: 'गांधीनगर', state: 'Gujarat'),

  // Uttar Pradesh & Central
  IndianCity(englishName: 'Lucknow', hindiName: 'लखनऊ', state: 'Uttar Pradesh'),
  IndianCity(englishName: 'Kanpur', hindiName: 'कानपुर', state: 'Uttar Pradesh'),
  IndianCity(englishName: 'Agra', hindiName: 'आगरा', state: 'Uttar Pradesh'),
  IndianCity(englishName: 'Varanasi', hindiName: 'वाराणसी', state: 'Uttar Pradesh'),
  IndianCity(englishName: 'Prayagraj', hindiName: 'प्रयागराज', state: 'Uttar Pradesh'),
  IndianCity(englishName: 'Bhopal', hindiName: 'भोपाल', state: 'Madhya Pradesh'),
  IndianCity(englishName: 'Indore', hindiName: 'इंदौर', state: 'Madhya Pradesh'),
  IndianCity(englishName: 'Gwalior', hindiName: 'ग्वालियर', state: 'Madhya Pradesh'),
  IndianCity(englishName: 'Jabalpur', hindiName: 'जबलपुर', state: 'Madhya Pradesh'),
  IndianCity(englishName: 'Ujjain', hindiName: 'उज्जैन', state: 'Madhya Pradesh'),

  // South
  IndianCity(englishName: 'Bengaluru', hindiName: 'बेंगलुरु', state: 'Karnataka'),
  IndianCity(englishName: 'Mysuru', hindiName: 'मैसूर', state: 'Karnataka'),
  IndianCity(englishName: 'Hyderabad', hindiName: 'हैदराबाद', state: 'Telangana'),
  IndianCity(englishName: 'Chennai', hindiName: 'चेन्नई', state: 'Tamil Nadu'),
  IndianCity(englishName: 'Coimbatore', hindiName: 'कोयंबटूर', state: 'Tamil Nadu'),
  IndianCity(englishName: 'Madurai', hindiName: 'मदुरै', state: 'Tamil Nadu'),
  IndianCity(englishName: 'Kochi', hindiName: 'कोच्चि', state: 'Kerala'),
  IndianCity(englishName: 'Thiruvananthapuram', hindiName: 'तिरुवनंतपुरम', state: 'Kerala'),
  IndianCity(englishName: 'Visakhapatnam', hindiName: 'विशाखापट्टनम', state: 'Andhra Pradesh'),
  IndianCity(englishName: 'Vijayawada', hindiName: 'विजयवाड़ा', state: 'Andhra Pradesh'),
  IndianCity(englishName: 'Goa', hindiName: 'गोवा', state: 'Goa'),

  // East & North East
  IndianCity(englishName: 'Kolkata', hindiName: 'कोलकाता', state: 'West Bengal'),
  IndianCity(englishName: 'Patna', hindiName: 'पटना', state: 'Bihar'),
  IndianCity(englishName: 'Ranchi', hindiName: 'राँची', state: 'Jharkhand'),
  IndianCity(englishName: 'Jamshedpur', hindiName: 'जमशेदपुर', state: 'Jharkhand'),
  IndianCity(englishName: 'Bhubaneswar', hindiName: 'भुवनेश्वर', state: 'Odisha'),
  IndianCity(englishName: 'Raipur', hindiName: 'रायपुर', state: 'Chhattisgarh'),
  IndianCity(englishName: 'Guwahati', hindiName: 'गुवाहाटी', state: 'Assam'),
];

class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onSelected;

  const LocationAutocompleteField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.onSelected,
  });

  @override
  State<LocationAutocompleteField> createState() => _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<IndianCity> _filteredCities = [];
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text.trim().toLowerCase();
    if (text.isEmpty) {
      _removeOverlay();
      return;
    }

    final matches = kTopIndianCities.where((city) {
      return city.englishName.toLowerCase().contains(text) ||
          city.hindiName.contains(text) ||
          city.state.toLowerCase().contains(text);
    }).take(6).toList();

    setState(() {
      _filteredCities = matches;
    });

    if (matches.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: 320,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: _filteredCities.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, idx) {
                  final city = _filteredCities[idx];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_city_rounded, size: 20, color: AppTheme.primaryGreen),
                    title: Text(
                      '${city.englishName} • ${city.hindiName}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text(
                      city.state,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    onTap: () {
                      widget.controller.text = city.englishName;
                      widget.onSelected?.call(city.englishName);
                      _removeOverlay();
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _isOpen = true;
  }

  void _removeOverlay() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.controller.text.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map_outlined, size: 20, color: Colors.blueAccent),
                      tooltip: 'Google Maps पर देखें (मुफ़्त)',
                      onPressed: () {
                        if (widget.controller.text.trim().isNotEmpty) {
                          MapLauncher.openLocation(query: widget.controller.text.trim());
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        widget.controller.clear();
                        _removeOverlay();
                      },
                    ),
                  ],
                )
              : null,
        ),
        validator: widget.validator,
        onTap: () {
          if (widget.controller.text.trim().isNotEmpty) {
            _onTextChanged();
          }
        },
      ),
    );
  }
}
