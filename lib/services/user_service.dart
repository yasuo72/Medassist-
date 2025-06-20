import 'package:dio/dio.dart';

class UserService {
  UserService(this._dio);

  final Dio _dio;

  static const _basePath = '/user';

  Future<String?> fetchEmergencyId() async {
    final resp = await _dio.get('$_basePath/emergency-id');
    return resp.data['data'] as String?;
  }

  Future<void> setEmergencyId(String emergencyId) async {
    await _dio.post('$_basePath/emergency-id', data: {'emergencyId': emergencyId});
  }
}
