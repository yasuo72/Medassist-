class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final String medicalTag;
  final String emergencyId;
  final String? avatarUrl;
  final String? summaryUrl; // URL to uploaded medical summary PDF/image
  final int? age;
  final String? gender;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.medicalTag,
    required this.emergencyId,
    this.avatarUrl,
    this.summaryUrl,
    this.age,
    this.gender,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? json['relation'] ?? '',
      medicalTag: json['medicalTag'] ?? json['medical_tag'] ?? '',
      emergencyId: json['emergencyId'] ?? json['emergency_id'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      summaryUrl: json['summaryUrl'] ?? json['summary_url'],
      age: json['age'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      // Backend expects `relation` (singular). Only include one key.
      'relation': relationship,
      // Assume backend uses snake_case for fields not in earlier GET payload.
      'medical_tag': medicalTag,
    };

    if (emergencyId.isNotEmpty) map['emergency_id'] = emergencyId;
    if (age != null) map['age'] = age;
    if (gender != null && gender!.isNotEmpty) map['gender'] = gender;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      map['avatar_url'] = avatarUrl;
    }
    if (summaryUrl != null && summaryUrl!.isNotEmpty) {
      map['summary_url'] = summaryUrl;
    }
    return map;
  }
}
