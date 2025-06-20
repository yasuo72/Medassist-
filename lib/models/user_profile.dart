import 'dart:convert';

class UserProfile {
  String name;
  String emergencyId;
  String bloodGroup;
  List<String> medicalConditions;
  List<String> allergies;
  List<String> pastSurgeries;
  List<String> currentMedications;
  List<String> reportFilePaths;
  String? faceScanPath;
  String? fingerprintData; // Placeholder for fingerprint data
  List<Map<String, String>> emergencyContacts = []; // Initialize with empty list

  UserProfile({
    this.name = '',
    this.emergencyId = '',
    this.bloodGroup = '',
    this.medicalConditions = const [],
    this.allergies = const [],
    this.pastSurgeries = const [],
    this.currentMedications = const [],
    this.reportFilePaths = const [],
    this.faceScanPath,
    this.fingerprintData,
    this.emergencyContacts = const [],
  });

  // Method to convert UserProfile to a Map for JSON encoding
  Map<String, dynamic> toJson() => {
    'name': name,
    'emergencyId': emergencyId,
    'bloodGroup': bloodGroup,
    'medicalConditions': medicalConditions,
    'allergies': allergies,
    'pastSurgeries': pastSurgeries,
    'currentMedications': currentMedications,
    'reportFilePaths': reportFilePaths,
    'faceScanPath': faceScanPath,
    'fingerprintData': fingerprintData,
    'emergencyContacts': emergencyContacts,
  };

  // Factory constructor to create UserProfile from a Map (JSON)
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? '',
    emergencyId: json['emergencyId'] as String? ?? '',
    bloodGroup: json['bloodGroup'] as String? ?? '',
    medicalConditions: List<String>.from(
      json['medicalConditions'] as List? ?? [],
    ),
    allergies: List<String>.from(json['allergies'] as List? ?? []),
    pastSurgeries: List<String>.from(json['pastSurgeries'] as List? ?? []),
    currentMedications: List<String>.from(
      json['currentMedications'] as List? ?? [],
    ),
    reportFilePaths: List<String>.from(json['reportFilePaths'] as List? ?? []),
    faceScanPath: json['faceScanPath'] as String?,
    fingerprintData: json['fingerprintData'] as String?,
    emergencyContacts: List<Map<String, String>>.from(
      (json['emergencyContacts'] as List? ?? []).map(
        (contact) => Map<String, String>.from(contact as Map),
      ),
    ),
  );

  // Helper to create a copy with new values
  UserProfile copyWith({
    String? name,
    String? emergencyId,
    String? bloodGroup,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? pastSurgeries,
    List<String>? currentMedications,
    List<String>? reportFilePaths,
    String? faceScanPath,
    String? fingerprintData,
    List<Map<String, String>>? emergencyContacts,
  }) {
    return UserProfile(
      name: name ?? this.name,
      emergencyId: emergencyId ?? this.emergencyId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      pastSurgeries: pastSurgeries ?? this.pastSurgeries,
      currentMedications: currentMedications ?? this.currentMedications,
      reportFilePaths: reportFilePaths ?? this.reportFilePaths,
      faceScanPath: faceScanPath ?? this.faceScanPath,
      fingerprintData: fingerprintData ?? this.fingerprintData,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }


}
