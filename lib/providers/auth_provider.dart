import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/appointment.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const String _userEmailKey = 'userEmail';
  static const String _passwordDigestKey = 'passwordDigest';
  static const String _legacyPasswordKey = 'userPassword';
  static const String _userRoleKey = 'userRole';
  static const String _firstNameKey = 'firstName';
  static const String _lastNameKey = 'lastName';
  static const String _profileImagePathKey = 'profileImagePath';
  static const String _phoneNumberKey = 'phoneNumber';
  static const String _addressKey = 'address';
  static const String _birthDateKey = 'birthDate';
  static const String _isAuthenticatedKey = 'isAuthenticated';
  static const String _appointmentsKey = 'appointments';

  final Uuid _uuid;

  String? _userEmail;
  String? _passwordDigest;
  String? _userRole;
  bool _isAuthenticated = false;

  String _firstName = 'John';
  String _lastName = 'Doe';
  String? _profileImagePath;
  String? _phoneNumber;
  String? _address;
  String? _birthDate;

  final List<Appointment> _appointments = [];

  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasLocalAccount =>
      (_userEmail?.isNotEmpty ?? false) && (_passwordDigest?.isNotEmpty ?? false);
  String get firstName => _firstName;
  String get lastName => _lastName;
  String? get profileImagePath => _profileImagePath;
  String? get phoneNumber => _phoneNumber;
  String? get address => _address;
  String? get birthDate => _birthDate;
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  bool get isPatient => _userRole == null || _userRole == 'PATIENT';
  bool get isLabAdmin => _userRole == 'LAB_ADMIN';
  bool get isDoctor => _userRole == 'DOCTOR';

  Appointment? get nextAppointment {
    if (_appointments.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final sortedAppointments = [..._appointments]
      ..sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));

    for (final appointment in sortedAppointments) {
      if (!appointment.scheduledAt.isBefore(now)) {
        return appointment;
      }
    }

    return sortedAppointments.last;
  }

  Future<void> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();

    _userEmail = _readTrimmedValue(prefs.getString(_userEmailKey));
    _passwordDigest = _readTrimmedValue(prefs.getString(_passwordDigestKey));
    _userRole = _readTrimmedValue(prefs.getString(_userRoleKey)) ?? 'PATIENT';
    _firstName = _readTrimmedValue(prefs.getString(_firstNameKey)) ?? 'John';
    _lastName = _readTrimmedValue(prefs.getString(_lastNameKey)) ?? 'Doe';
    _profileImagePath = _readTrimmedValue(prefs.getString(_profileImagePathKey));
    _phoneNumber = _readTrimmedValue(prefs.getString(_phoneNumberKey));
    _address = _readTrimmedValue(prefs.getString(_addressKey));
    _birthDate = _readTrimmedValue(prefs.getString(_birthDateKey));

    await _migrateLegacyPassword(prefs);
    _loadAppointmentsFromDisk(prefs.getString(_appointmentsKey));

    _isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;
    if (!hasLocalAccount) {
      _isAuthenticated = false;
    }

    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    await loadUserSession();
    return _isAuthenticated;
  }

  Future<void> register(
    String email,
    String password, {
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
    required String role,
    String? address,
    String? phone,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      throw Exception('Email and password are required.');
    }

    if (normalizedPassword.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    _userEmail = normalizedEmail;
    _passwordDigest = _createPasswordDigest(normalizedEmail, normalizedPassword);
    _firstName = firstName.trim();
    _lastName = lastName.trim();
    _address = _sanitizeOptional(address);
    _phoneNumber = _sanitizeOptional(phone);
    _birthDate = _sanitizeOptional(birthDate);
    _userRole = role.trim().isEmpty ? 'PATIENT' : role.trim();
    _appointments.clear();
    _isAuthenticated = true;

    try {
      await _saveToDisk();
      notifyListeners();
    } catch (error) {
      debugPrint('Registration Error: $error');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      throw Exception('Email and password are required.');
    }

    if (!hasLocalAccount) {
      throw Exception('No account found. Please create an account first.');
    }

    final candidateDigest =
        _createPasswordDigest(normalizedEmail, normalizedPassword);

    if (_userEmail != normalizedEmail || _passwordDigest != candidateDigest) {
      throw Exception('Invalid email or password.');
    }

    _isAuthenticated = true;
    _userRole ??= 'PATIENT';

    await _saveToDisk();
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> setUserRole(String role) async {
    _userRole = role.trim().isEmpty ? 'PATIENT' : role.trim();
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> updateProfile({
    required String first,
    required String last,
    String? phone,
    String? addr,
    String? dob,
    String? newPassword,
  }) async {
    _firstName = first.trim();
    _lastName = last.trim();
    _phoneNumber = _sanitizeOptional(phone);
    _address = _sanitizeOptional(addr);
    _birthDate = _sanitizeOptional(dob);

    final normalizedPassword = newPassword?.trim() ?? '';
    if (normalizedPassword.isNotEmpty) {
      if (normalizedPassword.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      final currentEmail = _userEmail;
      if (currentEmail == null || currentEmail.isEmpty) {
        throw Exception('No account found. Please create an account first.');
      }

      _passwordDigest = _createPasswordDigest(currentEmail, normalizedPassword);
    }

    await _saveToDisk();
    notifyListeners();
  }

  Future<void> updateProfileImage(String path) async {
    _profileImagePath = path.trim().isEmpty ? null : path.trim();
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> addAppointment({
    required String labName,
    required DateTime scheduledAt,
    List<String> testNames = const [],
    String? location,
  }) async {
    _appointments.add(
      Appointment(
        id: _uuid.v4(),
        labName: labName.trim(),
        scheduledAt: scheduledAt,
        testNames: testNames.where((test) => test.trim().isNotEmpty).toList(),
        status: 'Pending',
        location: _sanitizeOptional(location),
        bookedAt: DateTime.now(),
      ),
    );

    _appointments
        .sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));

    await _saveToDisk();
    notifyListeners();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final initialCount = _appointments.length;
    _appointments.removeWhere((appointment) => appointment.id == appointmentId);

    if (_appointments.length == initialCount) {
      return;
    }

    await _saveToDisk();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();

    await _writeNullableString(prefs, _userEmailKey, _userEmail);
    await _writeNullableString(prefs, _passwordDigestKey, _passwordDigest);
    await prefs.remove(_legacyPasswordKey);
    await _writeNullableString(prefs, _userRoleKey, _userRole ?? 'PATIENT');
    await prefs.setString(_firstNameKey, _firstName);
    await prefs.setString(_lastNameKey, _lastName);
    await prefs.setBool(_isAuthenticatedKey, _isAuthenticated);
    await _writeNullableString(prefs, _profileImagePathKey, _profileImagePath);
    await _writeNullableString(prefs, _phoneNumberKey, _phoneNumber);
    await _writeNullableString(prefs, _addressKey, _address);
    await _writeNullableString(prefs, _birthDateKey, _birthDate);

    if (_appointments.isEmpty) {
      await prefs.remove(_appointmentsKey);
    } else {
      final payload = jsonEncode(
        _appointments.map((appointment) => appointment.toJson()).toList(),
      );
      await prefs.setString(_appointmentsKey, payload);
    }
  }

  Future<void> _migrateLegacyPassword(SharedPreferences prefs) async {
    final legacyPassword = _readTrimmedValue(prefs.getString(_legacyPasswordKey));

    if ((_passwordDigest?.isNotEmpty ?? false) ||
        legacyPassword == null ||
        _userEmail == null) {
      return;
    }

    _passwordDigest = _createPasswordDigest(_userEmail!, legacyPassword);
    await prefs.setString(_passwordDigestKey, _passwordDigest!);
    await prefs.remove(_legacyPasswordKey);
  }

  void _loadAppointmentsFromDisk(String? payload) {
    _appointments.clear();

    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload) as List<dynamic>;
      _appointments.addAll(
        decoded
            .map((item) => Appointment.fromJson(Map<String, dynamic>.from(item)))
            .toList()
          ..sort(
            (first, second) =>
                first.scheduledAt.compareTo(second.scheduledAt),
          ),
      );
    } catch (error) {
      debugPrint('Appointment load error: $error');
    }
  }

  Future<void> _writeNullableString(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    if (value == null || value.isEmpty) {
      await prefs.remove(key);
      return;
    }

    await prefs.setString(key, value);
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String? _sanitizeOptional(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _readTrimmedValue(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _createPasswordDigest(String email, String password) {
    return sha256.convert(utf8.encode('${email.toLowerCase()}::$password')).toString();
  }
}
