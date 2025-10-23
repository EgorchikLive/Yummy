class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      avatarUrl: data['avatarUrl'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? email,
    String? username,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}