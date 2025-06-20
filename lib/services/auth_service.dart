import '../models/user.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService.instance;

  // Registers a user with name/email/password and returns the created user.
  Future<User> registerUser({required String name, required String email, required String password}) async {
    try {
      final Response res = await _api.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return _handleAuthSuccess(res);
    } catch (e) {
      rethrow;
    }
  }

  // Logs a user in with email/password.
  Future<User> loginUser({required String email, required String password}) async {
    try {
      final Response res = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return _handleAuthSuccess(res);
    } catch (e) {
      rethrow;
    }
  }

  User _handleAuthSuccess(Response res) {
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) {
      _api.setAuthToken(token);
    }
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Simulates sending OTP email. To be replaced with backend integration.
  Future<void> sendOtp(String email) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Simulates verifying OTP; returns true if OTP is six digits.
  Future<bool> verifyOtp(String email, String otp) async {
    await Future.delayed(const Duration(seconds: 2));
    return otp.length == 6;
  }
}
