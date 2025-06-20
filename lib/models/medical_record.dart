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
    return data.map((e) => MedicalRecord.fromMap(e as Map<String, dynamic>)).toList();
  }

  String get downloadUrl {
    // If filePath already absolute, return as-is. Otherwise prefix backend host.
    if (filePath.startsWith('http')) return filePath;
    return 'https://medassistbackend-production.up.railway.app/$filePath';
  }
}
