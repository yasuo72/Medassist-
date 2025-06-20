import 'package:dio/dio.dart';
import 'api_service.dart';

class QrService {
  QrService._();
  static final QrService _instance = QrService._();
  static QrService get instance => _instance;

  final Dio _dio = ApiService.instance.dio;

  Future<Map<String, String>> generateQr() async {
    final res = await _dio.get('/qr/generate');
    return Map<String, String>.from(res.data);
  }

  Future<String> getNfcPayload() async {
    final res = await _dio.get('/qr/nfc-payload');
    return res.data['payload'] as String;
  }
}
