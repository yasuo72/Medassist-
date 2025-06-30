# `lib/services/` – Platform & Network Helpers

Services are **stateless (or cache-light) classes** that perform platform IO, network calls, or heavy computations.  They are DI-friendly and used by Providers.

## Directory Map

| File | Description |
|------|-------------|
| `rag_chat_service.dart` | Talks to HuggingFace FastAPI `/chat` & `/passages`, handles JSON parse and timeout retry. |
| `crash_detection_service.dart` | Listens to accelerometer & gyroscope; triggers emergency flow on high-G event. |
| `notification_service.dart` | Local & push notifications (uses `flutter_local_notifications`). |
| `permissions_service.dart` | One-stop helper for camera, location, sensors. |

## Design Guidelines

1. **Pure Dart where possible** – no widget imports.  
2. Expose public async methods that throw typed `ServiceException` on failure.
3. Keep business logic **inside Provider**, not the Service.
4. When accessing platform channels, wrap with `try/catch` and return safe fallbacks for web.

```dart
class RagChatService {
  static const _base = ApiConfig.baseUrl;

  Future<String> ask(String question) async {
    final res = await http
        .post(Uri.parse('$_base/chat'), body: jsonEncode({'question': question}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw ServiceException('Bad status ${res.statusCode}');
    return jsonDecode(res.body)['answer'] as String;
  }
}
```

## Unit Testing

Mock with `http_testing` or `mockito` and verify JSON mapping.
