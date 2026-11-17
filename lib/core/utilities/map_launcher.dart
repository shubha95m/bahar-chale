import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  /// Opens Google Maps directions between origin and destination without metered API costs.
  static Future<bool> openDirections({
    required String origin,
    required String destination,
  }) async {
    final encodedOrigin = Uri.encodeComponent(origin.trim());
    final encodedDest = Uri.encodeComponent(destination.trim());
    final urlString = 'https://www.google.com/maps/dir/?api=1&origin=$encodedOrigin&destination=$encodedDest';
    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Opens a specific search query / location in Google Maps.
  static Future<bool> openLocation({required String query}) async {
    final encodedQuery = Uri.encodeComponent(query.trim());
    final urlString = 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
