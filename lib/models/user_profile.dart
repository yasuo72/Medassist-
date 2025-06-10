import 'dart:convert';

class UserProfile {
  String name;
  String bloodGroup;
  List<String> medicalConditions;
  List<String> allergies;
  List<String> pastSurgeries;
  List<String> currentMedications;
  List<String> reportFilePaths;
  String? faceScanPath;
  String? fingerprintData; // Placeholder for fingerprint data

  UserProfile({
    this.name = '',
    this.bloodGroup = '',
    this.medicalConditions = const [],
    this.allergies = const [],
    this.pastSurgeries = const [],
    this.currentMedications = const [],
    this.reportFilePaths = const [],
    this.faceScanPath,
    this.fingerprintData,
  });

  // Method to convert UserProfile to a Map for JSON encoding
  Map<String, dynamic> toJson() => {
        'name': name,
        'bloodGroup': bloodGroup,
        'medicalConditions': medicalConditions,
        'allergies': allergies,
        'pastSurgeries': pastSurgeries,
        'currentMedications': currentMedications,
        'reportFilePaths': reportFilePaths,
        'faceScanPath': faceScanPath,
        'fingerprintData': fingerprintData,
      };

  // Factory constructor to create UserProfile from a Map (JSON)
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? '',
        bloodGroup: json['bloodGroup'] as String? ?? '',
        medicalConditions: List<String>.from(json['medicalConditions'] as List? ?? []),
        allergies: List<String>.from(json['allergies'] as List? ?? []),
        pastSurgeries: List<String>.from(json['pastSurgeries'] as List? ?? []),
        currentMedications: List<String>.from(json['currentMedications'] as List? ?? []),
        reportFilePaths: List<String>.from(json['reportFilePaths'] as List? ?? []),
        faceScanPath: json['faceScanPath'] as String?,
        fingerprintData: json['fingerprintData'] as String?,
      );

  // Helper to create a copy with new values
  UserProfile copyWith({
    String? name,
    String? bloodGroup,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? pastSurgeries,
    List<String>? currentMedications,
    List<String>? reportFilePaths,
    String? faceScanPath,
    String? fingerprintData,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      pastSurgeries: pastSurgeries ?? this.pastSurgeries,
      currentMedications: currentMedications ?? this.currentMedications,
      reportFilePaths: reportFilePaths ?? this.reportFilePaths,
      faceScanPath: faceScanPath ?? this.faceScanPath,
      fingerprintData: fingerprintData ?? this.fingerprintData,
    );
  }
}
