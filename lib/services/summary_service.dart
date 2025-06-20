import 'package:dio/dio.dart';
import 'package:medassist_plus/models/user_profile.dart';
import 'api_service.dart';

class SummaryService {
  SummaryService._();
  static final SummaryService _instance = SummaryService._();
  static SummaryService get instance => _instance;

  final Dio _dio = ApiService.instance.dio;

  Future<String> generateSummary(UserProfile profile) async {
    final response = await _dio.post('/summary', data: {
      'profile': profile.toJson(),
    });
    return (response.data as Map<String, dynamic>)['summary'] as String? ?? '';
  }
}
