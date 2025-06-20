import 'package:flutter/foundation.dart';

/// Stores which parts of the user's medical profile are shared via QR / NFC.
/// In a real app you would persist this using SharedPreferences or secure
/// storage; for now it is kept in-memory.
class EmergencyAccessSettingsProvider extends ChangeNotifier {
  bool includeBasicInfo = true;      // ID & blood group
  bool includeAllergies = true;      // Allergy list
  bool includeConditions = true;     // Medical conditions
  bool includeMedications = true;    // Current meds
  bool includeContacts = true;       // Emergency contacts

  void toggleBasicInfo(bool value) {
    includeBasicInfo = value;
    notifyListeners();
  }

  void toggleAllergies(bool value) {
    includeAllergies = value;
    notifyListeners();
  }

  void toggleConditions(bool value) {
    includeConditions = value;
    notifyListeners();
  }

  void toggleMedications(bool value) {
    includeMedications = value;
    notifyListeners();
  }

  void toggleContacts(bool value) {
    includeContacts = value;
    notifyListeners();
  }

  /// Returns a map representation that the backend / QR generator can use
  /// to filter data.
  Map<String, bool> toMap() => {
        'basicInfo': includeBasicInfo,
        'allergies': includeAllergies,
        'conditions': includeConditions,
        'medications': includeMedications,
        'contacts': includeContacts,
      };
}
