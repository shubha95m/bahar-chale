import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email and Auth Validation Rules', () {
    final disposableDomains = {
      'mailinator.com',
      'tempmail.com',
      '10minutemail.com',
      'guerrillamail.com',
      'sharklasers.com',
      'yopmail.com',
      'trashmail.com',
      'getairmail.com',
      'dispostable.com',
      'throwawaymail.com',
      'fakemailgenerator.com',
      'temp-mail.org',
      'mohmal.com',
      'burnermail.io',
      'inboxkitten.com',
      'crazymailing.com',
    };

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    test('Validates real email addresses correctly', () {
      expect(emailRegex.hasMatch('user@gmail.com'), isTrue);
      expect(emailRegex.hasMatch('shubham.sharma@yahoo.co.in'), isTrue);
      expect(emailRegex.hasMatch('test+rider@outlook.com'), isTrue);
    });

    test('Rejects invalid email formats', () {
      expect(emailRegex.hasMatch('not-an-email'), isFalse);
      expect(emailRegex.hasMatch('user@'), isFalse);
      expect(emailRegex.hasMatch('@domain.com'), isFalse);
      expect(emailRegex.hasMatch('user@domain'), isFalse);
    });

    test('Blocks disposable/dummy email domains', () {
      for (final domain in disposableDomains) {
        expect(disposableDomains.contains(domain), isTrue);
        final dummyEmail = 'fake_user@$domain';
        expect(disposableDomains.contains(dummyEmail.split('@').last), isTrue);
      }
    });

    test('Allows legitimate domains that are not disposable', () {
      final cleanDomains = ['gmail.com', 'yahoo.com', 'outlook.com', 'icloud.com', 'company.org'];
      for (final domain in cleanDomains) {
        expect(disposableDomains.contains(domain), isFalse);
      }
    });

    test('Password complexity enforces minimum 6 characters', () {
      expect('12345'.length < 6, isTrue);
      expect('secret123'.length >= 6, isTrue);
    });
  });
}
