import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For MissingPluginException
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart' as sensors;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Background utility that listens to accelerometer data and triggers an
/// emergency workflow when a possible crash / hard fall is detected.
///
/// The implementation keeps CPU-budget low by using a simple threshold on the
/// acceleration magnitude (\u2248 2.5 g). For a hack-day demo this is usually
/// sufficient; it can later be replaced with a trained model or ML Kit
/// Activity Recognition.
class CrashDetectionService {
  static final CrashDetectionService _instance = CrashDetectionService._internal();
  factory CrashDetectionService() => _instance;
  CrashDetectionService._internal();

  StreamSubscription<sensors.AccelerometerEvent>? _accelSub;
  StreamSubscription<sensors.GyroscopeEvent>? _gyroSub;
  bool _running = false;
  // Simple correlation window
  DateTime? _lastAccelHit;
  DateTime? _lastGyroHit;
  BuildContext? _navContext;

  /// Starts listening for crashes. Call this once when the user enables the
  /// feature (e.g. from Settings).
  Future<void> start({BuildContext? context}) async {
    if (_running) return;
    _running = true;
    _navContext = context;

    // Listen to raw accelerometer & gyroscope events.
    await _initSensorStreams();

  }

  /// Stops listening to the accelerometer.
  void stop() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _running = false;
  }

  void _processAccel(sensors.AccelerometerEvent e) {
    if (!_running) return;
    final double mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    // Anything above ~25 m/s² (≈ 2.5 g) is considered a potential crash/fall.
    if (mag > 25) {
      _lastAccelHit = DateTime.now();
      _maybeTrigger();
    }
  }

  void _processGyro(sensors.GyroscopeEvent e) {
    if (!_running) return;
    final double mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    // Threshold ~20 rad/s indicates sudden rotation.
    if (mag > 20) {
      _lastGyroHit = DateTime.now();
      _maybeTrigger();
    }
  }

  void _maybeTrigger() {
    if (_lastAccelHit == null || _lastGyroHit == null) return;
    final diff = _lastAccelHit!.difference(_lastGyroHit!).abs();
    if (diff < const Duration(seconds: 1)) {
      _handleCrashDetected();
    }
  }

  Future<void> _handleCrashDetected() async {
    // Prevent duplicate triggers until restarted by user.
    stop();

    // 1. Navigate to the Emergency Access screen so that bystanders immediately
    //    see the patient's info.
    if (_navContext != null) {
      // Remove any stacked pages to ensure this screen is visible.
      Navigator.of(_navContext!)
          .pushNamedAndRemoveUntil('/emergency-access', (route) => true);
    }

    // 2. Acquire location (best-effort, permission handled gracefully).
    Position? pos;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        pos = await Geolocator.getCurrentPosition(
                timeLimit: const Duration(seconds: 5))
            .catchError((_) => null);
      }
    } catch (_) {
      // Ignore – location is optional.
    }

    // 3. Compose SOS text and launch the default SMS app.
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('primary_emergency_number');
    if (phone == null || phone.isEmpty) return;

    final qrUrl = prefs.getString('cloud_qr_url') ??
        'https://medassist.plus/demo-qr'; // Placeholder fallback

    final message = Uri.encodeComponent(
        '🚨 MedAssist+ SOS\nPossible crash detected.\nLocation: '
        '${pos != null ? '${pos.latitude},${pos.longitude}' : 'unknown'}\nQR: $qrUrl');

    final uri = Uri.parse('sms:$phone?body=$message');
    // ignore: deprecated_member_use
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Robustly attach to sensors, retrying if the plugin isn't yet registered (happens
  // when running in a fresh background isolate).
  Future<void> _initSensorStreams() async {
    try {
      _accelSub = sensors.accelerometerEvents.listen(_processAccel);
      _gyroSub = sensors.gyroscopeEvents.listen(_processGyro);
    } on MissingPluginException {
      // Wait a bit and retry – the plugin registration might still be in progress.
      await Future.delayed(const Duration(milliseconds: 500));
      await _initSensorStreams();
    }
  }

  /// Manual trigger that can be hooked to a "Test" button in settings.
  Future<void> simulateCrash() => _handleCrashDetected();
}
