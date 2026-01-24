import 'package:dio/dio.dart';
import 'package:medassist_plus/models/user_profile.dart';
import 'api_service.dart';

class SummaryService {
  SummaryService._();
  static final SummaryService _instance = SummaryService._();
  static SummaryService get instance => _instance;

  final Dio _dio = ApiService.instance.dio;

  // Base URL for the Python ai_summarizer service deployed on Railway.
  // Replace the placeholder with your actual deployed URL, e.g.
  // https://medassist-ai-summarizer-production.up.railway.app
  static const String _aiSummarizerBaseUrl =
      'https://YOUR-AI-SUMMARIZER-URL.up.railway.app';

  Future<String> generateSummary(UserProfile profile) async {
    // Build a plain-text description of the user's medical profile that the
    // ai_summarizer service can summarize safely.
    final buffer = StringBuffer();
    if (profile.name.isNotEmpty) {
      buffer.writeln('Patient name: ${profile.name}.');
    }
    if (profile.bloodGroup.isNotEmpty) {
      buffer.writeln('Blood group: ${profile.bloodGroup}.');
    }
    if (profile.medicalConditions.isNotEmpty) {
      buffer.writeln(
        'Medical conditions: ${profile.medicalConditions.join(', ')}.',
      );
    }
    if (profile.allergies.isNotEmpty) {
      buffer.writeln('Allergies: ${profile.allergies.join(', ')}.');
    }
    if (profile.currentMedications.isNotEmpty) {
      buffer.writeln(
        'Current medications: ${profile.currentMedications.join(', ')}.',
      );
    }
    if (profile.pastSurgeries.isNotEmpty) {
      buffer.writeln('Past surgeries: ${profile.pastSurgeries.join(', ')}.');
    }

    final text =
        buffer.isNotEmpty
            ? buffer.toString()
            : 'No detailed medical information available for this profile.';

    final response = await _dio.post(
      '$_aiSummarizerBaseUrl/summarize-text',
      data: {'text': text},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['summary'] as String? ?? '';
    }
    return '';
  }
}
