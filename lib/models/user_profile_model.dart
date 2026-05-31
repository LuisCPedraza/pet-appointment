class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? photoUrl;
  final bool isActive;
  final DateTime? createdAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      name: json['full_name'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      photoUrl: json['photo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  factory UserProfileModel.fallback({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String role,
    String? photoUrl,
    bool isActive = true,
  }) {
    return UserProfileModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      photoUrl: photoUrl,
      isActive: isActive,
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? photoUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final letters = parts.map((part) => part[0]).take(2).join();
    return letters.isEmpty ? 'U' : letters.toUpperCase();
  }
}
