import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class ChatProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> ask(String question) async {
    if (question.trim().isEmpty) return null;
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await http.post(
        Uri.parse(ApiConfig.chat),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      );
      if (resp.statusCode == 200) {
        final answer = jsonDecode(resp.body)['answer'] as String;
        return answer;
      } else {
        debugPrint('Chat error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e, st) {
      debugPrint('Chat exception: $e\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
