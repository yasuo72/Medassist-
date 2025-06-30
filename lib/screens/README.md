# `lib/screens/` – UI Pages

This folder contains **all visual pages** (Flutter `Widget`s) displayed in the MedAssist+ app.  Each page is a top-level, routeable screen.

## Structure & Conventions

```
lib/screens/
 ├─ splash_screen.dart
 ├─ onboarding/
 │    ├─ onboarding_screen.dart
 │    └─ intro_card.dart
 ├─ login_screen.dart
 ├─ home_dashboard.dart
 ├─ profile_creation/
 │    └─ profile_creation_screen.dart
 ├─ emergency/
 │    ├─ emergency_qr_screen.dart
 │    ├─ emergency_access_screen.dart
 │    └─ emergency_info_screen.dart
 ├─ chatbot_screen.dart            # Offline KB mode
 ├─ online_chatbot_screen.dart     # RAG API mode
 └─ … (more)
```

1. **Snake-case filenames**  `my_feature_screen.dart`  
2. Each file exports *one* `StatefulWidget` (suffix `Screen`).  
3. Route names live as static constants inside the widget (`static const routeName = '/profile-create';`).  This is consumed by `go_router` in `main.dart`.
4. **Responsive layout**:  
   * Use `LayoutBuilder` + `MediaQuery` breakpoints `>600`, `>900` where needed.  
   * All paddings use `const EdgeInsets.symmetric(horizontal: 16)` unless overridden.
5. **Glass-morphism style** helper: `CommonGlassCard` (see `widgets/glass_card.dart`).
6. Animations follow `flutter_animate` with a maximum duration of **400 ms** to stay snappy.

## Adding a New Screen

1. Create `lib/screens/your_feature/your_feature_screen.dart`.  
2. Implement widget & route constant.
3. Register route in `main.dart`’s `GoRouter` (or helper `routes.dart`).
4. If it needs persistent state, add a Provider in `lib/providers`.

## Dark-Mode
All screens read `Theme.of(context).brightness` and defer colors to `AppTheme` tokens so the same code works in light & dark.

## Testing
* Widget tests live under `test/screens/` with file name mirror (`*_test.dart`).
* Use golden tests with `flutter_test`’s `matchesGoldenFile` for critical UI (dashboard, chatbot).
