import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/medical_record.dart';
import '../services/receipt_service.dart';

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

  List<MedicalRecord> _records = [];
  List<MedicalRecord> get records => _records;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchRecords(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (userId.isEmpty) {
        _records = [];
        return;
      }

      final receipts = await ReceiptService.instance.listReceipts(userId);
      _records = receipts.map(MedicalRecord.fromMap).toList();
    } catch (_) {
      // log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadRecord({
    required String title,
    required String recordType,
    required String filePath,
    required String userId,
  }) async {
    const allowedTypes = [
      'Lab Report',
      'Prescription',
      'Imaging',
      'Clinical Note',
      'Other',
    ];
    final sanitizedType =
        allowedTypes.contains(recordType) ? recordType : 'Other';

    try {
      if (userId.isEmpty) return false;

      final file = File(filePath);
      final cloudinaryUrl = await ReceiptService.instance.uploadFile(file);
      if (cloudinaryUrl.isEmpty) return false;

      final items = <String>['$sanitizedType: $title'];

      final result = await ReceiptService.instance.createReceipt(
        userId: userId,
        vendor: title,
        date: DateTime.now().toIso8601String(),
        items: items,
        total: '0',
        cloudinaryFileUrl: cloudinaryUrl,
        documentType: sanitizedType,
      );

      if (result['success'] == true &&
          result['receipt'] is Map<String, dynamic>) {
        final record = MedicalRecord.fromMap(
          result['receipt'] as Map<String, dynamic>,
        );
        _records.insert(0, record);
        notifyListeners();
        return true;
      }
    } catch (e, st) {
      debugPrint('UploadRecord exception: $e\n$st');
    }
    return false;
  }

  Future<bool> deleteRecord(String id, {required String userId}) async {
    try {
      await ReceiptService.instance.deleteReceipt(
        id,
        userId: userId.isNotEmpty ? userId : null,
      );
      _records.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (_) {}
    return false;
  }

  Future<String?> fetchAiSummary(String id) async {
    try {
      final data = await ReceiptService.instance.getReceipt(id);
      if (data != null && data['summary'] is String) {
        return data['summary'] as String;
      }
    } catch (_) {}
    return null;
  }

  // Add auth headers if your backend requires them.
}
