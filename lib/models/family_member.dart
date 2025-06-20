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
      medicalTag: json['medicalTag'] ?? '',
      emergencyId: json['emergencyId'] ?? '',
      avatarUrl: json['avatarUrl'],
      summaryUrl: json['summaryUrl'],
      age: json['age'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'medicalTag': medicalTag,
      'emergencyId': emergencyId,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (summaryUrl != null) 'summaryUrl': summaryUrl,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
    };
  }
}
