import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/core/localization/app_language.dart';
import 'package:bahar_chale/core/localization/app_strings.dart';

void main() {
  group('Localization and Language Switching', () {
    test('AppLanguage code parsing parses correctly', () {
      expect(AppLanguage.fromCode('en'), equals(AppLanguage.english));
      expect(AppLanguage.fromCode('hi'), equals(AppLanguage.hindi));
      expect(AppLanguage.fromCode(null), equals(AppLanguage.hindi)); // Default
      expect(AppLanguage.fromCode('unknown'), equals(AppLanguage.hindi));
    });

    test('AppStrings provides correct Hindi translations', () {
      const strings = AppStrings(AppLanguage.hindi);
      expect(strings.isHindi, isTrue);
      expect(strings.appTitle, equals('बाहर चलें (Bahar Chale)'));
      expect(strings.navHomeText, equals('होम (Home)'));
      expect(strings.navSearchText, equals('सवारी खोजें (Find Rides)'));
      expect(strings.navMyTravelText, equals('मेरी यात्राएं (My Travel)'));
      expect(strings.navMessagesText, equals('संदेश (Messages)'));
      expect(strings.navProfileText, equals('प्रोफ़ाइल (Profile)'));
      expect(strings.actionWantRideText, equals('मुझे यात्रा करनी है'));
      expect(strings.actionGiveRideText, equals('अपनी ड्राइविंग राइड शेयर करें'));
      expect(strings.offerRideTitle, equals('अपनी ड्राइविंग राइड शेयर करें'));
      expect(strings.needRideTitle, equals('अपनी यात्रा का अनुरोध शेयर करें'));
      expect(strings.availableDrivesTab, equals('उपलब्ध ड्राइविंग राइड्स'));
      expect(strings.passengerRequestsTab, equals('यात्रियों के अनुरोध'));
      expect(strings.tabIncomingText, equals('मिले अनुरोध (Incoming)'));
    });

    test('AppStrings provides correct English translations', () {
      const strings = AppStrings(AppLanguage.english);
      expect(strings.isHindi, isFalse);
      expect(strings.appTitle, equals('Bahar Chale'));
      expect(strings.navHomeText, equals('Home'));
      expect(strings.navSearchText, equals('Find Rides'));
      expect(strings.navMyTravelText, equals('My Travel'));
      expect(strings.navMessagesText, equals('Messages'));
      expect(strings.navProfileText, equals('Profile'));
      expect(strings.actionWantRideText, equals('Find a Ride'));
      expect(strings.actionGiveRideText, equals('Offer a Ride'));
      expect(strings.tabIncomingText, equals('Incoming Requests'));
    });
  });
}
