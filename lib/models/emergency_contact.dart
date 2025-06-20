class EmergencyContact {
  final String id;
  final String name;
  final String relationship;
  final String phoneNumber;
  final bool isPriority;
  final bool shareMedicalSummary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.isPriority = false,
    this.shareMedicalSummary = false,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phoneNumber: json['phone'] ?? json['phoneNumber'] ?? '',
      isPriority: json['isPriority'] ?? false,
      shareMedicalSummary: json['shareMedicalSummary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relationship': relationship,
        'phone': phoneNumber,
        'isPriority': isPriority,
        'shareMedicalSummary': shareMedicalSummary,
      };

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phoneNumber,
    bool? isPriority,
    bool? shareMedicalSummary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPriority: isPriority ?? this.isPriority,
      shareMedicalSummary: shareMedicalSummary ?? this.shareMedicalSummary,
    );
  }
}
