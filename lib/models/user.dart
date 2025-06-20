class User {
  final String id;
  final String name;
  final String email;
  final String? emergencyId;
  final String? faceEmbedding;
  final String? fingerprintHash;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emergencyId,
    this.faceEmbedding,
    this.fingerprintHash,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emergencyId: json['emergencyId'] as String?,
      faceEmbedding: json['faceEmbedding'] as String?,
      fingerprintHash: json['fingerprintHash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'emergencyId': emergencyId,
      'faceEmbedding': faceEmbedding,
      'fingerprintHash': fingerprintHash,
    };
  }
}
