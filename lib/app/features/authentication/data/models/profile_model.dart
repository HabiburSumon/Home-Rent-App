class ProfileResponse {
  final bool success;
  final ProfileData data;

  ProfileResponse({
    required this.success,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] as bool? ?? false,
      data: ProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ProfileData {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert to User entity if needed
  ProfileUser toProfileUser() {
    return ProfileUser(
      name: name,
      email: email,
      profileImageUrl: _generateAvatarUrl(name),
    );
  }

  String _generateAvatarUrl(String name) {
    // Generate avatar from name initials
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join()
        : 'U';
    return 'https://ui-avatars.com/api/?name=$initials&background=0D8ABC&color=fff&size=200';
  }
}

// Your existing ProfileUser class (or update it)
class ProfileUser {
  final String name;
  final String email;
  final String profileImageUrl;

  const ProfileUser({
    required this.name,
    required this.email,
    required this.profileImageUrl,
  });

  factory ProfileUser.fromProfileData(ProfileData data) {
    final initials = data.name.isNotEmpty
        ? data.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join()
        : 'U';
    return ProfileUser(
      name: data.name,
      email: data.email,
      profileImageUrl:
      'https://ui-avatars.com/api/?name=$initials&background=0D8ABC&color=fff&size=200',
    );
  }
}