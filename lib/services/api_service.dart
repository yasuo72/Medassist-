import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton wrapper around Dio that automatically attaches the stored JWT
/// to every request and exposes helpers for saving/clearing the token.
class ApiService {
  ApiService._internal() {
    dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // TODO: Optionally handle 401 for automatic logout/refresh.
          return handler.next(e);
        },
      ),
    );
  }

  static final ApiService instance = ApiService._internal();

  final Dio dio = Dio();

  // ---- Helpers -------------------------------------------------------------

  static const String _tokenKey = 'auth_token';
  // NOTE: change to your actual backend base URL or use dotenv.
  static const String _baseUrl = 'https://medassistbackend-production.up.railway.app/api';

  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
