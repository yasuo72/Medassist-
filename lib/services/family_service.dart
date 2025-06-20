import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:medassist_plus/models/family_member.dart';
import 'package:medassist_plus/services/api_service.dart';

/// Service layer that talks to the backend /family endpoints.
class FamilyService {
  // existing code...
  Future<Map<String, dynamic>> getSummaryByEmergencyId(String emergencyId) async {
    try {
      final response = await _dio.get('$_basePath/summary/$emergencyId');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  final Dio _dio = ApiService.instance.dio;

  static const _basePath = '/family';

  Future<List<FamilyMember>> fetchMembers() async {
    try {
      final response = await _dio.get(_basePath);
      // backend expected to return { success: true, data: [...] }
      final data = response.data;
      final List<dynamic> list = data is Map<String, dynamic> ? data['data'] ?? [] : data;
      return list.map((e) => FamilyMember.fromJson(e)).toList();
    } on DioException catch (e) {
      // Rethrow with readable message for UI
      throw Exception((e.response?.data is Map<String, dynamic> ? e.response?.data['message'] : e.response?.data?.toString()) ?? 'Failed to load family members');
    }
  }

  Future<FamilyMember> addMember(FamilyMember member) async {
    try {
      final response = await _dio.post(_basePath, data: member.toJson());
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] ?? data : data;
      return FamilyMember.fromJson(json);
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map<String, dynamic> ? e.response?.data['message'] : e.response?.data?.toString()) ?? 'Failed to add family member');
    }
  }

  Exception _handleDioError(DioException e) {
    final msg = (e.response?.data is Map<String, dynamic>
            ? e.response?.data['message']
            : e.response?.data?.toString()) ??
        e.message;
    return Exception(msg ?? 'Request failed');
  }

  Future<String> uploadSummary(File file) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
        ),
      });
      final response = await _dio.post('$_basePath/summary', data: form);
      // backend expected to return { success: true, url: '...' }
      final data = response.data;
      return data is Map<String, dynamic> ? data['url'] ?? '' : data.toString();
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map<String, dynamic> ? e.response?.data['message'] : e.response?.data?.toString()) ?? 'Failed to upload summary');
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map<String, dynamic> ? e.response?.data['message'] : e.response?.data?.toString()) ?? 'Failed to delete family member');
    }
  }

  Future<FamilyMember> updateMember(FamilyMember member) async {
    try {
      final response = await _dio.put('$_basePath/${member.id}', data: member.toJson());
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] ?? data : data;
      return FamilyMember.fromJson(json);
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map<String, dynamic> ? e.response?.data['message'] : e.response?.data?.toString()) ?? 'Failed to update family member');
    }
  }
}
