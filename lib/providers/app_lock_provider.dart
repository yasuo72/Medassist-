import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides app-level biometric lock functionality.
class AppLockProvider extends ChangeNotifier {
  static const _kEnabledKey = 'app_lock_enabled';

  bool _enabled = false;
  bool _loaded = false;
  bool get enabled => _enabled;

  Future<void> _load() async {
    if (_loaded) return;
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_kEnabledKey) ?? false;
    _loaded = true;
  }

  /// Call during app start.
  Future<void> init() => _load();

  Future<void> toggle(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kEnabledKey, value);
    _enabled = value;
    notifyListeners();
  }

  /// Returns true if access granted. When disabled always returns true.
  Future<bool> authenticate() async {
    await _load();
    if (!_enabled) return true;

    final auth = LocalAuthentication();
    final can = await auth.canCheckBiometrics || await auth.isDeviceSupported();
    if (!can) return false;

    return auth.authenticate(
      localizedReason: 'Unlock MedAssist+',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}
