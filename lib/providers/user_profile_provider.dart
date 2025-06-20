import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile _userProfile = UserProfile();
  static const String _profileKey = 'userProfile';

  UserProfile get userProfile => _userProfile;

  UserProfileProvider() {
    _loadProfile();
  }

  final ProfileService _profileService = ProfileService.instance;

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      try {
        _userProfile = UserProfile.fromJson(json.decode(profileJson) as Map<String, dynamic>);
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding profile JSON: $e');
        }
        _userProfile = UserProfile(); // Reset to default if decoding fails
      }
    } else {
      _userProfile = UserProfile(); // Initialize with default if no data found
    }

    // Attempt to fetch latest profile from backend (if authenticated)
    try {
      final backendProfile = await _profileService.fetchProfile();
      _userProfile = backendProfile;
      // save locally for offline use
      await _saveProfile();
    } catch (e) {
      if (kDebugMode) {
        print('[UserProfileProvider] Unable to fetch profile from backend: $e');
      }
      // Ignore error, stay with local profile
    }
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String profileJson = json.encode(_userProfile.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _userProfile = newProfile;

    // Persist to backend first; fall back to local only on failure
    try {
      final savedProfile = await _profileService.updateProfile(newProfile);
      _userProfile = savedProfile;
    } catch (e) {
      if (kDebugMode) {
        print('[UserProfileProvider] Failed to update profile on backend: $e');
      }
      // We still proceed to save locally to avoid data loss
    }

    await _saveProfile();
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _userProfile = _userProfile.copyWith(name: name);
    await _saveProfile();
    notifyListeners();
  }

  Future<void> updateBloodGroup(String bloodGroup) async {
    _userProfile = _userProfile.copyWith(bloodGroup: bloodGroup);
    await _saveProfile();
    notifyListeners();
  }

  Future<void> updateMedicalConditions(List<String> conditions) async {
    _userProfile = _userProfile.copyWith(medicalConditions: conditions);
    await _saveProfile();
    notifyListeners();
  }

  Future<void> updateAllergies(List<String> allergies) async {
    _userProfile = _userProfile.copyWith(allergies: allergies);
    await _saveProfile();
    notifyListeners();
  }

  Future<void> updatePastSurgeries(List<String> surgeries) async {
    _userProfile = _userProfile.copyWith(pastSurgeries: surgeries);
    await _saveProfile();
    notifyListeners();
  }

  // Getters for face recognition and emergency info
  String get userId => _userProfile.emergencyId;
  String get name => _userProfile.name;
  List<Map<String, String>> get emergencyContacts => _userProfile.emergencyContacts;
  List<String> get medicalConditions => _userProfile.medicalConditions;
  String get bloodGroup => _userProfile.bloodGroup;
  List<String> get allergies => _userProfile.allergies;

  Future<void> updateCurrentMedications(List<String> medications) async {
    _userProfile = _userProfile.copyWith(currentMedications: medications);
    await _saveProfile();
    notifyListeners();
  }

  Future<void> addReportFilePath(String path) async {
    final updatedPaths = List<String>.from(_userProfile.reportFilePaths)..add(path);
    _userProfile = _userProfile.copyWith(reportFilePaths: updatedPaths);
    await _saveProfile();
    notifyListeners();
  }

  Future<void> removeReportFilePath(String path) async {
    final updatedPaths = List<String>.from(_userProfile.reportFilePaths)..remove(path);
    _userProfile = _userProfile.copyWith(reportFilePaths: updatedPaths);
    await _saveProfile();
    notifyListeners();
  }

  // Placeholder for face scan update
  Future<void> updateFaceScanPath(String path) async {
    _userProfile = _userProfile.copyWith(faceScanPath: path);
    await _saveProfile();
    notifyListeners();
  }

  // Updates face scan enrollment status
  Future<void> setFaceScanEnrolled(bool isEnrolled) async {
    _userProfile = _userProfile.copyWith(faceScanPath: isEnrolled ? "enrolled" : ""); // Store "enrolled" or empty
    await _saveProfile();
    notifyListeners();
  }

  // Updates fingerprint enrollment status
  Future<void> setFingerprintEnrolled(bool isEnrolled) async {
    _userProfile = _userProfile.copyWith(fingerprintData: isEnrolled ? "enrolled" : ""); // Store "enrolled" or empty
    await _saveProfile();
    notifyListeners();
  }

  // Clear profile data (e.g., on logout)
  Future<void> clearProfile() async {
    _userProfile = UserProfile();
    await _saveProfile();
    notifyListeners();
  }
}
