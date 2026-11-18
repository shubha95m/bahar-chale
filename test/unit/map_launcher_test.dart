import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/utilities/map_launcher.dart';

void main() {
  group('MapLauncher URL Builder', () {
    test('buildDirectionsUrl prioritizes exact GPS coordinates when available', () {
      final url = MapLauncher.buildDirectionsUrl(
        origin: 'Suratpura',
        destination: 'Begun',
        originArea: 'Samariya Khurd, Begun Tehsil',
        destinationArea: 'Begun Tehsil',
        originLat: 25.1052788,
        originLon: 75.0884306,
        destinationLat: 24.9860286,
        destinationLon: 75.0132209,
      );

      expect(url, contains('api=1'));
      expect(url, contains('origin=25.1052788%2C75.0884306'));
      expect(url, contains('destination=24.9860286%2C75.0132209'));
    });

    test('buildDirectionsUrl disambiguates with area and country when coordinates are absent', () {
      final url = MapLauncher.buildDirectionsUrl(
        origin: 'Suratpura',
        destination: 'Begun',
        originArea: 'Samariya Khurd, Begun Tehsil',
        destinationArea: 'Begun Tehsil',
      );

      expect(url, contains('api=1'));
      // Expect origin to include Suratpura, Samariya Khurd, Begun Tehsil, India
      final decoded = Uri.decodeFull(url);
      expect(decoded, contains('origin=Suratpura, Samariya Khurd, Begun Tehsil, India'));
      expect(decoded, contains('destination=Begun, Begun Tehsil, India'));
    });

    test('buildDirectionsUrl does not duplicate India or area if already in city name', () {
      final url = MapLauncher.buildDirectionsUrl(
        origin: 'Pune, Maharashtra, India',
        destination: 'Mumbai, Maharashtra, India',
      );

      final decoded = Uri.decodeFull(url);
      expect(decoded, contains('origin=Pune, Maharashtra, India'));
      expect(decoded, contains('destination=Mumbai, Maharashtra, India'));
      expect('India'.allMatches(decoded).length, equals(2)); // Exactly 2 times (one per param)
    });

    test('buildLocationUrl formats coordinates or disambiguated query correctly', () {
      final coordUrl = MapLauncher.buildLocationUrl(
        query: 'Suratpura',
        lat: 25.1052788,
        lon: 75.0884306,
      );
      expect(coordUrl, contains('query=25.1052788%2C75.0884306'));

      final textUrl = MapLauncher.buildLocationUrl(
        query: 'Suratpura',
        area: 'Samariya Khurd',
      );
      final decoded = Uri.decodeFull(textUrl);
      expect(decoded, contains('query=Suratpura, Samariya Khurd, India'));
    });
  });
}
