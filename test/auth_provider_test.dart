import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:online_medicine_lab/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthProvider', () {
    test('register stores a password digest instead of plaintext', () async {
      final provider = AuthProvider();

      await provider.register(
        'user@example.com',
        'secret123',
        firstName: 'User',
        lastName: 'Example',
        gender: 'male',
        birthDate: '2000-01-01',
        role: 'PATIENT',
      );

      final prefs = await SharedPreferences.getInstance();

      expect(provider.isAuthenticated, isTrue);
      expect(prefs.getString('userPassword'), isNull);
      expect(prefs.getString('passwordDigest'), isNotNull);
      expect(prefs.getString('passwordDigest'), isNot('secret123'));
    });

    test('legacy plaintext password is migrated and login still works', () async {
      SharedPreferences.setMockInitialValues({
        'userEmail': 'user@example.com',
        'userPassword': 'secret123',
        'firstName': 'User',
        'lastName': 'Example',
        'isAuthenticated': false,
      });

      final provider = AuthProvider();
      await provider.loadUserSession();

      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('userPassword'), isNull);
      expect(prefs.getString('passwordDigest'), isNotNull);
      expect(provider.isAuthenticated, isFalse);

      await provider.login('user@example.com', 'secret123');

      expect(provider.isAuthenticated, isTrue);
    });

    test('appointments are saved and restored as typed models', () async {
      final provider = AuthProvider();

      await provider.register(
        'user@example.com',
        'secret123',
        firstName: 'User',
        lastName: 'Example',
        gender: 'male',
        birthDate: '2000-01-01',
        role: 'PATIENT',
      );

      final scheduledAt = DateTime(2026, 4, 15, 9, 30);
      await provider.addAppointment(
        labName: 'City Medical Lab',
        scheduledAt: scheduledAt,
        testNames: const ['Full Blood Count'],
        location: 'Kabul',
      );

      final reloadedProvider = AuthProvider();
      await reloadedProvider.loadUserSession();

      expect(reloadedProvider.appointments, hasLength(1));

      final appointment = reloadedProvider.appointments.single;
      expect(appointment.labName, 'City Medical Lab');
      expect(appointment.scheduledAt, scheduledAt);
      expect(appointment.testNames, equals(const ['Full Blood Count']));
      expect(appointment.location, 'Kabul');
    });

    test('profile image is saved and restored', () async {
      final provider = AuthProvider();

      await provider.register(
        'user@example.com',
        'secret123',
        firstName: 'User',
        lastName: 'Example',
        gender: 'male',
        birthDate: '2000-01-01',
        role: 'PATIENT',
      );

      const profileImage = 'data:image/png;base64,ZmFrZQ==';
      await provider.updateProfileImage(profileImage);

      final reloadedProvider = AuthProvider();
      await reloadedProvider.loadUserSession();

      expect(reloadedProvider.profileImagePath, profileImage);
    });
  });
}
