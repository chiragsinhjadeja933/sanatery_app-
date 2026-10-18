class DepartmentModel {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}
