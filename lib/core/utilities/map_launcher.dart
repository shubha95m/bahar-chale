import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  /// Builds Google Maps directions URL with exact coordinates or disambiguated address parts.
  static String buildDirectionsUrl({
    required String origin,
    required String destination,
    String? originArea,
    String? destinationArea,
    double? originLat,
    double? originLon,
    double? destinationLat,
    double? destinationLon,
  }) {
    // 1. Build precise origin query
    String originQuery;
    if (originLat != null && originLon != null && originLat != 0 && originLon != 0) {
      originQuery = '$originLat,$originLon';
    } else {
      final parts = <String>[origin.trim()];
      if (originArea != null && originArea.trim().isNotEmpty) {
        final cleanArea = originArea.trim();
        if (!origin.toLowerCase().contains(cleanArea.toLowerCase())) {
          parts.add(cleanArea);
        }
      }
      if (!parts.any((p) => p.toLowerCase().contains('india'))) {
        parts.add('India');
      }
      originQuery = parts.join(', ');
    }

    // 2. Build precise destination query
    String destQuery;
    if (destinationLat != null && destinationLon != null && destinationLat != 0 && destinationLon != 0) {
      destQuery = '$destinationLat,$destinationLon';
    } else {
      final parts = <String>[destination.trim()];
      if (destinationArea != null && destinationArea.trim().isNotEmpty) {
        final cleanArea = destinationArea.trim();
        if (!destination.toLowerCase().contains(cleanArea.toLowerCase())) {
          parts.add(cleanArea);
        }
      }
      if (!parts.any((p) => p.toLowerCase().contains('india'))) {
        parts.add('India');
      }
      destQuery = parts.join(', ');
    }

    final encodedOrigin = Uri.encodeComponent(originQuery);
    final encodedDest = Uri.encodeComponent(destQuery);
    return 'https://www.google.com/maps/dir/?api=1&origin=$encodedOrigin&destination=$encodedDest';
  }

  /// Opens Google Maps directions between origin and destination.
  /// Intelligently builds precise geographic queries using area and coordinates
  /// so Google Maps resolves the exact intended local places without ambiguity.
  static Future<bool> openDirections({
    required String origin,
    required String destination,
    String? originArea,
    String? destinationArea,
    double? originLat,
    double? originLon,
    double? destinationLat,
    double? destinationLon,
  }) async {
    final urlString = buildDirectionsUrl(
      origin: origin,
      destination: destination,
      originArea: originArea,
      destinationArea: destinationArea,
      originLat: originLat,
      originLon: originLon,
      destinationLat: destinationLat,
      destinationLon: destinationLon,
    );
    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Builds Google Maps location search URL.
  static String buildLocationUrl({
    required String query,
    String? area,
    double? lat,
    double? lon,
  }) {
    String finalQuery;
    if (lat != null && lon != null && lat != 0 && lon != 0) {
      finalQuery = '$lat,$lon';
    } else {
      final parts = <String>[query.trim()];
      if (area != null && area.trim().isNotEmpty) {
        final cleanArea = area.trim();
        if (!query.toLowerCase().contains(cleanArea.toLowerCase())) {
          parts.add(cleanArea);
        }
      }
      if (!parts.any((p) => p.toLowerCase().contains('india'))) {
        parts.add('India');
      }
      finalQuery = parts.join(', ');
    }

    final encodedQuery = Uri.encodeComponent(finalQuery);
    return 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
  }

  /// Opens a specific search query / location in Google Maps.
  static Future<bool> openLocation({
    required String query,
    String? area,
    double? lat,
    double? lon,
  }) async {
    final urlString = buildLocationUrl(
      query: query,
      area: area,
      lat: lat,
      lon: lon,
    );
    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
