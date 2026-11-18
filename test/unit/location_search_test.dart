import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/services/location_search_service.dart';

void main() {
  group('LocationSearchService & Suggestions', () {
    test('instant local city search returns matching Indian cities', () async {
      final results = await LocationSearchService.search('pune');
      expect(results.isNotEmpty, isTrue);

      final match = results.firstWhere((r) => r.city.toLowerCase() == 'pune');
      expect(match.city, equals('Pune'));
      expect(match.isCity, isTrue);
      expect(match.state, equals('Maharashtra'));
    });

    test('hindi city search matches correctly', () async {
      final results = await LocationSearchService.search('दिल्ली');
      expect(results.isNotEmpty, isTrue);

      final match = results.firstWhere((r) => r.city.toLowerCase() == 'delhi');
      expect(match.city, equals('Delhi'));
      expect(match.isCity, isTrue);
    });

    test('empty query returns empty list safely without exception', () async {
      final results = await LocationSearchService.search('');
      expect(results.isEmpty, isTrue);

      final whitespaceResults = await LocationSearchService.search('   ');
      expect(whitespaceResults.isEmpty, isTrue);
    });

    test('fullLocationText formats area when distinct from city', () {
      const suggestionWithArea = LocationSuggestion(
        title: 'Hinjawadi Phase 1',
        subtitle: 'Pune, Maharashtra, India',
        city: 'Pune',
        area: 'Hinjawadi Phase 1',
        state: 'Maharashtra',
      );
      expect(suggestionWithArea.fullLocationText, equals('Pune (Hinjawadi Phase 1)'));

      const suggestionCityOnly = LocationSuggestion(
        title: 'Mumbai',
        subtitle: 'Maharashtra, India',
        city: 'Mumbai',
        state: 'Maharashtra',
        isCity: true,
      );
      expect(suggestionCityOnly.fullLocationText, equals('Mumbai'));
    });
  });
}
