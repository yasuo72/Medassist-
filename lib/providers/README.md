# `lib/providers/` – State Management Layer

MedAssist+ uses **Provider / ChangeNotifier** as the primary state-management solution.  Each provider wraps a single domain (profile, chat, language, etc.) and exposes reactive data to widgets.

## Files

| Provider | Responsibility |
|----------|----------------|
| `user_profile_provider.dart` | CRUD user profile, persist to SQLite, notify dashboard & emergency QR screens. |
| `chat_provider.dart` | Handles REST calls to FastAPI `/chat`, manages loading / error state. |
| `language_provider.dart` | Current locale, switches at runtime and reloads `AppLocalizations`. |
| `theme_provider.dart` *(TBD)* | Light / dark toggle and seed colors. |

## Principles

1. **Single source of truth** – one provider per domain.
2. **No build-context in providers**; inject services instead.
3. **Async work** via `Future<void>` methods with `try/catch` and loading bool.
4. **Persistence**: heavy data (profiles) saved in SQLite, light prefs in `SharedPreferences`.

## Adding a Provider

```dart
class FooProvider extends ChangeNotifier {
  final FooService _service;
  FooProvider(this._service);

  List<Foo> _items = [];
  List<Foo> get items => _items;

  Future<void> load() async {
    _items = await _service.fetch();
    notifyListeners();
  }
}
```

Register it once in `main.dart` inside `MultiProvider`:

```dart
ChangeNotifierProvider(create: (_) => FooProvider(FooService())),
```

## Testing
* Use `flutter_test`’s `ChangeNotifierProvider` with a fake service.
* Verify that `notifyListeners` fires and UI rebuilds accordingly.
