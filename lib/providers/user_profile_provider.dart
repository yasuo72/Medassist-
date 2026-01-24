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

    // Notify listeners immediately with locally cached profile so the UI can display data without waiting for server round-trip
    notifyListeners();

    // Attempt to fetch latest profile from backend (if authenticated)
    try {
      final backendProfile = await _profileService.fetchProfile();
      // Merge with existing local data to avoid losing fields missing from backend response
      _userProfile = _mergeProfiles(_userProfile, backendProfile);
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

  /// Pushes the current local profile state to the backend API, ensuring data is synced.
  Future<void> _pushLocalToBackend() async {
    try {
      await _profileService.updateProfile(_userProfile);
    } catch (e) {
      if (kDebugMode) {
        print('[UserProfileProvider] Failed to push local profile to backend: $e');
      }
    }
  }

  // Helper that merges non-empty / non-null fields from [incoming] into [base].
  UserProfile _mergeProfiles(UserProfile base, UserProfile incoming) {
    bool _isNotEmpty(String? s) => s != null && s.isNotEmpty;
    List<T>? _nonEmptyList<T>(List<T>? l) => (l != null && l.isNotEmpty) ? l : null;

    return base.copyWith(
      name: _isNotEmpty(incoming.name) ? incoming.name : null,
      emergencyId: _isNotEmpty(incoming.emergencyId) ? incoming.emergencyId : null,
      bloodGroup: _isNotEmpty(incoming.bloodGroup) ? incoming.bloodGroup : null,
      medicalConditions: _nonEmptyList(incoming.medicalConditions),
      allergies: _nonEmptyList(incoming.allergies),
      pastSurgeries: _nonEmptyList(incoming.pastSurgeries),
      currentMedications: _nonEmptyList(incoming.currentMedications),
      reportFilePaths: _nonEmptyList(incoming.reportFilePaths),
      faceScanPath: _isNotEmpty(incoming.faceScanPath) ? incoming.faceScanPath : null,
      fingerprintData: _isNotEmpty(incoming.fingerprintData) ? incoming.fingerprintData : null,
      emergencyContacts: _nonEmptyList(incoming.emergencyContacts),
    );
  }

  Future<void> fetchLatestProfile() async {
    try {
      final backendProfile = await _profileService.fetchProfile();
      _userProfile = _mergeProfiles(_userProfile, backendProfile);
      await _saveProfile();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[UserProfileProvider] Failed to fetch latest profile: $e');
      }
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    // Merge new changes locally to preserve any existing data not included in [newProfile]
    _userProfile = _mergeProfiles(_userProfile, newProfile);

    // Persist to backend first; fall back to local only on failure
    try {
      final savedProfile = await _profileService.updateProfile(newProfile);
      // Backend may return partial profile – merge again to avoid data loss
      _userProfile = _mergeProfiles(_userProfile, savedProfile);
    } catch (e) {
      if (kDebugMode) {
        print('[UserProfileProvider] Failed to update profile on backend: $e');
      }
      // We still proceed to save locally to avoid data loss
    }

    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _userProfile = _userProfile.copyWith(name: name);
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  Future<void> updateBloodGroup(String bloodGroup) async {
    _userProfile = _userProfile.copyWith(bloodGroup: bloodGroup);
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  Future<void> updateMedicalConditions(List<String> conditions) async {
    _userProfile = _userProfile.copyWith(medicalConditions: conditions);
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  Future<void> updateAllergies(List<String> allergies) async {
    _userProfile = _userProfile.copyWith(allergies: allergies);
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  Future<void> updatePastSurgeries(List<String> surgeries) async {
    _userProfile = _userProfile.copyWith(pastSurgeries: surgeries);
    await _saveProfile();
    await _pushLocalToBackend();
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
    await _pushLocalToBackend();
    notifyListeners();
  }

  Future<void> addReportFilePath(String path) async {
    final updatedPaths = List<String>.from(_userProfile.reportFilePaths)..add(path);
    _userProfile = _userProfile.copyWith(reportFilePaths: updatedPaths);
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  Future<void> removeReportFilePath(String path) async {
    final updatedPaths = List<String>.from(_userProfile.reportFilePaths)..remove(path);
    _userProfile = _userProfile.copyWith(reportFilePaths: updatedPaths);
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  // Placeholder for face scan update
  Future<void> updateFaceScanPath(String path) async {
    _userProfile = _userProfile.copyWith(faceScanPath: path);
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  // Updates face scan enrollment status
  Future<void> setFaceScanEnrolled(bool isEnrolled) async {
    _userProfile = _userProfile.copyWith(faceScanPath: isEnrolled ? "enrolled" : ""); // Store "enrolled" or empty
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  // Updates fingerprint enrollment status
  Future<void> setFingerprintEnrolled(bool isEnrolled) async {
    _userProfile = _userProfile.copyWith(fingerprintData: isEnrolled ? "enrolled" : ""); // Store "enrolled" or empty
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }

  // Clear profile data (e.g., on logout)
  Future<void> clearProfile() async {
    _userProfile = UserProfile();
    await _saveProfile();
    await _pushLocalToBackend();
    notifyListeners();
  }
}
