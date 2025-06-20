import 'dart:io';

import 'package:dio/dio.dart';
import 'api_service.dart';

class MedicalRecordService {
  final ApiService _api = ApiService.instance;

  Future<void> uploadReports(List<File> files, {String recordType = 'Report'}) async {
    if (files.isEmpty) return;

    // Backend expects single file per request with `title` and `recordType` fields
    for (final f in files) {
      final fileName = f.uri.pathSegments.last;
      final formData = FormData.fromMap({
        'title': fileName,
        'recordType': recordType,
        'file': await MultipartFile.fromFile(f.path, filename: fileName),
      });
      await _api.dio.post('/records/upload', data: formData);
    }
  }

  Future<int> fetchReportsCount() async {
    try {
      final response = await _api.dio.get('/records');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).length;
      }
    } catch (_) {}
    return 0;
  }

  Future<void> createRecord({required String bloodGroup, required String allergies, required String conditions, String? surgeries}) async {
    await _api.dio.post('/records', data: {
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'conditions': conditions,
      'surgeries': surgeries,
    });
  }
}
