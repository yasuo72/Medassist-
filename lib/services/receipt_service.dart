import 'dart:io';

import 'package:dio/dio.dart';
import 'api_service.dart';

/// Service for the MediAssist Receipt Store backend.
///
/// This talks to the standalone Node.js + Gemini service that accepts
/// cleaned OCR JSON for medical/pharmacy receipts, generates a summary,
/// and stores it in a MongoDB-based "Receipt Store".
class ReceiptService {
  ReceiptService._();
  static final ReceiptService _instance = ReceiptService._();
  static ReceiptService get instance => _instance;

  final Dio _dio = ApiService.instance.dio;

  /// Base URL of the Receipt Store backend.
  ///
  /// Replace this with your deployed Railway URL, e.g.
  /// https://medassist-receipts-production.up.railway.app/api/receipts
  static const String _baseUrl =
      'https://reciptbackend-production.up.railway.app/api/receipts';

  /// Create a new receipt from cleaned OCR JSON and get back
  /// both the stored metadata and the Gemini summary text.
  Future<Map<String, dynamic>> createReceipt({
    required String userId,
    required String vendor,
    required String date,
    required List<String> items,
    required String total,
    String? cloudinaryFileUrl,
    String? documentType,
    String? ocrText,
    Map<String, dynamic>? ocrJson,
  }) async {
    final payload = <String, dynamic>{
      'userId': userId,
      'vendor': vendor,
      'date': date,
      'items': items,
      'total': total,
    };

    if (cloudinaryFileUrl != null && cloudinaryFileUrl.isNotEmpty) {
      payload['cloudinaryFileUrl'] = cloudinaryFileUrl;
    }
    if (documentType != null && documentType.isNotEmpty) {
      payload['documentType'] = documentType;
    }
    if (ocrText != null && ocrText.isNotEmpty) {
      payload['ocrText'] = ocrText;
    }
    if (ocrJson != null && ocrJson.isNotEmpty) {
      payload['ocrJson'] = ocrJson;
    }

    final response = await _dio.post(_baseUrl, data: payload);

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'success': false, 'message': 'Unexpected response format'};
  }

  /// Upload an image or PDF file to the receipt-backend. The backend will
  /// store it in Cloudinary and return the secure URL. This endpoint does
  /// not create a receipt record; after upload, call [createReceipt] with
  /// the returned URL and OCR data.
  Future<String> uploadFile(File file) async {
    final fileName =
        file.uri.pathSegments.isNotEmpty
            ? file.uri.pathSegments.last
            : 'receipt';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dio.post('$_baseUrl/upload', data: formData);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['url'] as String? ?? '';
    }
    return '';
  }

  /// List all receipts for a given user.
  Future<List<Map<String, dynamic>>> listReceipts(String userId) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {'userId': userId},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['receipts'] is List) {
      return List<Map<String, dynamic>>.from(data['receipts'] as List);
    }
    return const [];
  }

  /// Fetch a single receipt (including the decrypted summary).
  Future<Map<String, dynamic>?> getReceipt(String id) async {
    final response = await _dio.get('$_baseUrl/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return null;
  }

  /// Delete a stored receipt. Optionally pass [userId] so the backend can
  /// enforce ownership.
  Future<void> deleteReceipt(String id, {String? userId}) async {
    await _dio.delete(
      '$_baseUrl/$id',
      queryParameters: userId != null ? {'userId': userId} : null,
    );
  }
}
