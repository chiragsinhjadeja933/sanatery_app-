class ShiftModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final double durationHours;
  final bool isActive;

  ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.durationHours = 8.0,
    required this.isActive,
  });

  String get formattedSchedule {
    final start = startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
    final end = endTime.length >= 5 ? endTime.substring(0, 5) : endTime;
    return '$start - $end (${durationHours.toStringAsFixed(1)} hrs)';
  }

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      durationHours: double.tryParse(json['duration_hours']?.toString() ?? '8.0') ?? 8.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
    };
  }
}
