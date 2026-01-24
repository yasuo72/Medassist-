import 'dart:convert';

class MedicalRecord {
  final String id;
  final String title;
  final String recordType;
  final String filePath;
  final String mimeType;
  final DateTime createdAt;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.recordType,
    required this.filePath,
    required this.mimeType,
    required this.createdAt,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    // If this map looks like a receipt-backend payload (has "vendor"),
    // treat it as a receipt coming from /api/receipts.
    if (map.containsKey('vendor')) {
      final dynamic idValue = map['id'] ?? map['_id'];
      final String vendor = (map['vendor'] ?? 'Untitled') as String;
      final String cloudinaryUrl = (map['cloudinaryUrl'] ?? '') as String;

      final dynamic createdAtRaw = map['createdAt'] ?? map['date'];
      DateTime createdAt;
      if (createdAtRaw is DateTime) {
        createdAt = createdAtRaw;
      } else if (createdAtRaw is String) {
        createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
      } else {
        createdAt = DateTime.now();
      }

      return MedicalRecord(
        id: idValue?.toString() ?? '',
        title: vendor,
        // For receipt-backed medical records we treat the type as a
        // generic "Medical Receipt".
        recordType: 'Medical Receipt',
        filePath: cloudinaryUrl,
        // MIME type is not exposed by the receipt-backend; callers can
        // infer from the file extension if needed.
        mimeType: '',
        createdAt: createdAt,
      );
    }

    // Legacy Node.js medical-record backend shape
    return MedicalRecord(
      id: map['_id'] ?? map['id'] as String,
      title: map['title'] as String,
      recordType: map['recordType'] as String,
      filePath: map['filePath'] as String,
      mimeType: map['fileMimetype'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  static List<MedicalRecord> listFromJson(String source) {
    final List<dynamic> data = jsonDecode(source) as List<dynamic>;
    return data
        .map((e) => MedicalRecord.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  String get downloadUrl {
    // If filePath already absolute, return as-is. Otherwise prefix backend host.
    if (filePath.startsWith('http')) return filePath;
    return 'https://medassistbackend-production.up.railway.app/$filePath';
  }
}
