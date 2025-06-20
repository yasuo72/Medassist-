import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Manages storage + retrieval of the user's own Emergency ID and
/// the (hashed) password protecting it.
///
/// Uses [FlutterSecureStorage] so values are stored in the platform
/// key-store rather than shared_preferences.
class EmergencyIdProvider extends ChangeNotifier {
  static const _keyEmergencyId = 'emergency_id';
  static const _keyPasswordHash = 'emergency_id_pwd_hash';

  // secure storage singleton
  final FlutterSecureStorage _storage;

  EmergencyIdProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  String? _cachedEmergencyId;
  bool _unlocked = false;

  /// Returns true if `_unlocked` AND [_cachedEmergencyId] is not null.
  bool get isUnlocked => _unlocked && _cachedEmergencyId != null;

  String? get emergencyId => isUnlocked ? _cachedEmergencyId : null;

  /// Persist the emergency ID **unencrypted** but in secure storage.
  Future<void> setEmergencyId(String id) async {
    await _storage.write(key: _keyEmergencyId, value: id);
    _cachedEmergencyId = id;
    notifyListeners();
  }

  /// Sets / changes the password by hashing it with SHA-256 and storing
  /// the hex digest. Existing password (if any) will be overwritten.
  Future<void> setPassword(String password) async {
    final digest = sha256.convert(utf8.encode(password)).toString();
    await _storage.write(key: _keyPasswordHash, value: digest);
    // lock after changing password
    _unlocked = false;
    notifyListeners();
  }

  /// Clears the cached flag so ID becomes hidden again (e.g. after timeout).
  void lock() {
    if (_unlocked) {
      _unlocked = false;
      notifyListeners();
    }
  }

  /// Validates [password] against stored hash.  Returns true on success and
  /// sets [_unlocked] so [emergencyId] can be read.  Caller should call
  /// [lock] after an appropriate timeout.
  Future<bool> unlock(String password) async {
    final storedHash = await _storage.read(key: _keyPasswordHash);
    if (storedHash == null) return false; // no password set
    final digest = sha256.convert(utf8.encode(password)).toString();
    if (digest == storedHash) {
      _cachedEmergencyId ??=
          await _storage.read(key: _keyEmergencyId); // may be null
      _unlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Loads cached ID (locked) at startup so we can show UI state quickly.
  Future<void> init() async {
    _cachedEmergencyId = await _storage.read(key: _keyEmergencyId);
    _unlocked = false;
  }
}
