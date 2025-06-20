import '../models/emergency_contact.dart';
import 'api_service.dart';

class EmergencyContactService {
  final _api = ApiService.instance;

  Future<List<EmergencyContact>> fetchContacts() async {
    final res = await _api.dio.get('/user/contacts');
    // API wraps response as { success: true, data: [...] }
    final wrapper = res.data;
    final data = (wrapper is Map<String, dynamic>) ? wrapper['data'] as List<dynamic>? ?? [] : wrapper as List<dynamic>;
    return data.map((e) => EmergencyContact.fromJson(e)).toList();
  }

  Future<void> addContact({required String name, required String relationship, required String phone, bool isPriority = false, bool shareMedicalSummary = false}) async {
    await _api.dio.post('/user/contacts', data: {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'isPriority': isPriority,
      'shareMedicalSummary': shareMedicalSummary,
    });
  }

  Future<void> updateContact(EmergencyContact contact) async {
    await _api.dio.put('/user/contacts/${contact.id}', data: contact.toJson());
  }

  Future<void> deleteContact(String id) async {
    await _api.dio.delete('/user/contacts/$id');
  }
}