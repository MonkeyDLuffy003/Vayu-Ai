enum VayuUserRole {
  developer,
  tester,
  user,
}

enum VayuUserTier {
  free,
  pro,
}

class VayuUser {
  final String uid;
  final String email;
  final String displayName;
  final VayuUserRole role;
  final VayuUserTier tier;
  final String preferredLanguage;
  final DateTime createdAt;

  const VayuUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.tier,
    required this.preferredLanguage,
    required this.createdAt,
  });

  // ============================================================
  // ROLE HELPERS
  // ============================================================

  bool get isDeveloper =>
      role == VayuUserRole.developer;

  bool get isTester =>
      role == VayuUserRole.tester;

  bool get isRegularUser =>
      role == VayuUserRole.user;

  // ============================================================
  // COPY
  // ============================================================

  VayuUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    VayuUserRole? role,
    VayuUserTier? tier,
    String? preferredLanguage,
    DateTime? createdAt,
  }) {
    return VayuUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName:
          displayName ?? this.displayName,
      role: role ?? this.role,
      tier: tier ?? this.tier,
      preferredLanguage:
          preferredLanguage ??
              this.preferredLanguage,
      createdAt:
          createdAt ?? this.createdAt,
    );
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'tier': tier.name,
      'preferredLanguage':
          preferredLanguage,
      'createdAt':
          createdAt.toIso8601String(),
    };
  }

  factory VayuUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return VayuUser(
      uid: json['uid'] as String? ?? '',
      email:
          json['email'] as String? ?? '',
      displayName:
          json['displayName'] as String? ??
              'Vayu User',
      role: _roleFromString(
        json['role'] as String?,
      ),
      tier: _tierFromString(
        json['tier'] as String?,
      ),
      preferredLanguage:
          json['preferredLanguage']
                  as String? ??
              'en',
      createdAt:
          DateTime.tryParse(
                json['createdAt']
                        as String? ??
                    '',
              ) ??
              DateTime.now(),
    );
  }

  // ============================================================
  // ENUM CONVERSION
  // ============================================================

  static VayuUserRole _roleFromString(
    String? value,
  ) {
    switch (value) {
      case 'developer':
        return VayuUserRole.developer;

      case 'tester':
        return VayuUserRole.tester;

      case 'user':
        return VayuUserRole.user;

      default:
        return VayuUserRole.user;
    }
  }

  static VayuUserTier _tierFromString(
    String? value,
  ) {
    switch (value) {
      case 'pro':
        return VayuUserTier.pro;

      case 'free':
      default:
        return VayuUserTier.free;
    }
  }
}
