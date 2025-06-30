import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple client for the MedAssist+ Hugging Face Space RAG chatbot.
class RagChatService {
  // Replace with your Space URL if you fork/rename.
  static const String _base = 'https://yasuo7-chatbot2.hf.space';
  static const String _chatPath = '/chat';
  static const String _passagesPath = '/passages';

  Uri _u(String path) => Uri.parse(_base + path);

  Future<String> ask(String question) async {
    final req = http.Request('POST', _u(_chatPath))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'question': question});

    final resp = await req.send();
    if (resp.statusCode != 200) {
      final body = await resp.stream.bytesToString();
      throw Exception('Server error ${resp.statusCode}: $body');
    }

    final raw = await resp.stream.bytesToString();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json['answer'] as String? ?? raw;
    } catch (_) {
      return raw; // fallback if not JSON
    }
  }

  Future<List<String>> passages(String question) async {
    final resp = await http.post(
      _u(_passagesPath),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = data['passages'] as List<dynamic>;
      return list.cast<String>();
    }
    return [];
  }
}
