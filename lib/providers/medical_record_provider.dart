import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/medical_record.dart';

class MedicalRecordProvider with ChangeNotifier {
  MedicalRecordProvider({String? authToken}) : _authToken = authToken;

  String? _authToken;
  String? get authToken => _authToken;

  // Allows updating token after login
  void setAuthToken(String token, {bool silent = false}) {
    if (_authToken == token) return;
    _authToken = token;
    if (!silent) notifyListeners();
  }

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  static const String _baseUrl = 'https://medassistbackend-production.up.railway.app/api/records';

  List<MedicalRecord> _records = [];
  List<MedicalRecord> get records => _records;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchRecords() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        _records = MedicalRecord.listFromJson(response.body);
      }
    } catch (_) {
      // log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadRecord({required String title, required String recordType, required String filePath}) async {
    const allowedTypes = ['Lab Report', 'Prescription', 'Imaging', 'Clinical Note', 'Other'];
    final sanitizedType = allowedTypes.contains(recordType) ? recordType : 'Other';
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'));
    request.headers.addAll(_headers());
    request.fields['title'] = title;
    request.fields['recordType'] = sanitizedType;

    // Backend expects multipart key named 'recordFile'
    request.files.add(await http.MultipartFile.fromPath('recordFile', filePath));

    try {
      final streamed = await request.send();
      final respStr = await streamed.stream.bytesToString();
      debugPrint('UploadRecord -> status ${streamed.statusCode}; body: $respStr');
      if (streamed.statusCode == 200) {
        final record = MedicalRecord.fromMap(jsonDecode(respStr));
        _records.insert(0, record);
        notifyListeners();
        return true;
      }
    } catch (e, st) {
      debugPrint('UploadRecord exception: $e\n$st');
    }
    return false;
  }

  Future<bool> deleteRecord(String id) async {
    try {
      final resp = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers(),
      );
      if (resp.statusCode == 200) {
        _records.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<String?> fetchAiSummary(String id) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/$id/ai-summary'),
        headers: _headers(),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['summary'] as String?;
      }
    } catch (_) {}
    return null;
  }

  // Add auth headers if your backend requires them.
}
