import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../widgets/location_autocomplete_field.dart' show kTopIndianCities;

class LocationSuggestion {
  final String title;
  final String subtitle;
  final String primaryName;
  final String city;
  final String? area;
  final String? state;
  final double? latitude;
  final double? longitude;
  final bool isCity;

  const LocationSuggestion({
    required this.title,
    required this.subtitle,
    String? primaryName,
    required this.city,
    this.area,
    this.state,
    this.latitude,
    this.longitude,
    this.isCity = false,
  }) : primaryName = primaryName ?? city;

  String get fullLocationText {
    if (area != null && area!.isNotEmpty && area != primaryName && area != city) {
      return '$primaryName ($area)';
    }
    return primaryName;
  }
}

class LocationSearchService {
  static final http.Client _client = http.Client();

  /// Searches exact places, landmarks, sectors, stations, and cities.
  /// 100% Free via OpenStreetMap/Photon with zero Google Cloud API cost.
  static Future<List<LocationSuggestion>> search(String query, {bool isHindi = false}) async {
    final clean = query.trim();
    if (clean.isEmpty) return const [];

    final List<LocationSuggestion> results = [];
    final Set<String> seen = {};

    // 1. Instant local matching from top Indian cities
    final cleanLower = clean.toLowerCase();
    for (final c in kTopIndianCities) {
      if (c.englishName.toLowerCase().contains(cleanLower) ||
          c.hindiName.contains(clean) ||
          c.state.toLowerCase().contains(cleanLower)) {
        final key = '${c.englishName}_${c.state}'.toLowerCase();
        if (seen.add(key)) {
          results.add(LocationSuggestion(
            title: isHindi ? c.getDisplayName(isHindi: true) : c.englishName,
            subtitle: '${c.state}, India',
            primaryName: c.englishName,
            city: c.englishName,
            state: c.state,
            isCity: true,
          ));
        }
      }
    }

    // 2. Exact place search via Photon API (India geographic bias)
    if (clean.length >= 2) {
      try {
        final url = Uri.parse(
          'https://photon.komoot.io/api/?q=${Uri.encodeComponent(clean)}&lat=20.5937&lon=78.9629&limit=8',
        );

        final response = await _client.get(
          url,
          headers: {'User-Agent': 'BaharChale/1.0 (RideSharing; FreeCommunity)'},
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
          final features = data['features'] as List<dynamic>? ?? [];

          for (final f in features) {
            final props = (f as Map<String, dynamic>)['properties'] as Map<String, dynamic>? ?? {};
            final country = props['country'] as String?;

            // Filter for places within India or with high relevance
            if (country != null && country.toLowerCase() != 'india') {
              continue;
            }

            final name = (props['name'] as String?)?.trim() ?? '';
            if (name.isEmpty) continue;

            final osmCity = (props['city'] as String?)?.trim();
            final osmDistrict = (props['district'] as String?)?.trim();
            final osmCounty = (props['county'] as String?)?.trim();
            final state = (props['state'] as String?)?.trim();
            final street = (props['street'] as String?)?.trim();
            final locality = (props['locality'] as String?)?.trim();

            // The primary place name the user searched for and wants to select
            final primaryPlace = name;

            // Collect parent context areas (e.g. Samariya Khurd, Begun Tehsil, street, etc.)
            final parentParts = <String>[];
            if (street != null && street.isNotEmpty && street != primaryPlace) parentParts.add(street);
            if (locality != null && locality.isNotEmpty && locality != primaryPlace && !parentParts.contains(locality)) {
              parentParts.add(locality);
            }
            if (osmCity != null && osmCity.isNotEmpty && osmCity != primaryPlace && !parentParts.contains(osmCity)) {
              parentParts.add(osmCity);
            }
            if (osmCounty != null && osmCounty.isNotEmpty && osmCounty != primaryPlace && !parentParts.contains(osmCounty)) {
              parentParts.add(osmCounty);
            }
            if (osmDistrict != null && osmDistrict.isNotEmpty && osmDistrict != primaryPlace && !parentParts.contains(osmDistrict)) {
              parentParts.add(osmDistrict);
            }

            final area = parentParts.isNotEmpty ? parentParts.join(', ') : null;

            final geometry = f['geometry'] as Map<String, dynamic>?;
            final coords = geometry?['coordinates'] as List<dynamic>?;
            double? lon;
            double? lat;
            if (coords != null && coords.length >= 2) {
              lon = (coords[0] as num).toDouble();
              lat = (coords[1] as num).toDouble();
            }

            final subParts = <String>[];
            if (area != null && area.isNotEmpty) subParts.add(area);
            if (state != null && state.isNotEmpty) subParts.add(state);
            subParts.add('India');

            final subtitle = subParts.join(', ');
            final key = '$primaryPlace-$area-$state'.toLowerCase();

            if (seen.add(key)) {
              results.add(LocationSuggestion(
                title: primaryPlace,
                subtitle: subtitle,
                primaryName: primaryPlace,
                city: primaryPlace, // ALWAYS the entered/selected place name!
                area: area,
                state: state,
                latitude: lat,
                longitude: lon,
                isCity: props['type'] == 'city' || props['type'] == 'town',
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('Location search network fallback: $e');
      }
    }

    return results;
  }
}
