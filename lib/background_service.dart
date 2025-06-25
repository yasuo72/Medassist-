import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'services/crash_detection_service.dart';

/// Initializes a foreground service that keeps crash detection running even
/// when the app is in background or the screen is off. Call `initializeService`
/// once during app startup (e.g. in `main.dart` before `runApp`).
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // If already running, no-op.
  if (await service.isRunning()) return;

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'medassist_crash_detection',
      initialNotificationTitle: 'MedAssist+ Crash Detection',
      initialNotificationContent: 'Monitoring for crashes and falls',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: _onStart,
      onBackground: (service) async => true,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) {
  // Keep Dart VM alive.
  DartPluginRegistrant.ensureInitialized();

  // Start crash detection without navigation context.
  CrashDetectionService().start();

  // Optionally stop service if user disables detection.
  service.on('stopService').listen((_) {
    CrashDetectionService().stop();
    service.stopSelf();
  });
}
