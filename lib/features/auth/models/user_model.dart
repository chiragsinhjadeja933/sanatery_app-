enum UserRole {
  admin,
  manager,
  supervisor;

  static UserRole fromString(String? roleStr) {
    switch (roleStr?.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'MANAGER':
        return UserRole.manager;
      case 'SUPERVISOR':
        return UserRole.supervisor;
      default:
        return UserRole.supervisor;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.supervisor:
        return 'Supervisor';
    }
  }

  String get apiValue {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.manager:
        return 'MANAGER';
      case UserRole.supervisor:
        return 'SUPERVISOR';
    }
  }
}

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String phone;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.phone,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : username;
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isManagerOrAdmin => role == UserRole.admin || role == UserRole.manager;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role.apiValue,
      'phone': phone,
    };
  }
}
