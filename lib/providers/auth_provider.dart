import 'package:flutter/foundation.dart';

/// Simple authentication provider that stores the JWT for API requests.
/// Expand with login/refresh logic as needed.
class AuthProvider with ChangeNotifier {
  String? _token;

  AuthProvider({String? token}) : _token = token;

  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void clearToken() {
    _token = null;
    notifyListeners();
  }
}
