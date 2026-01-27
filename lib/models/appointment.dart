class Appointment {
  final String id;
  final String labName;
  final DateTime scheduledAt;
  final List<String> testNames;
  final String status;
  final String? location;
  final DateTime bookedAt;

  const Appointment({
    required this.id,
    required this.labName,
    required this.scheduledAt,
    this.testNames = const [],
    this.status = 'Pending',
    this.location,
    required this.bookedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      labName: json['labName'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      testNames: (json['testNames'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(),
      status: (json['status'] as String?) ?? 'Pending',
      location: json['location'] as String?,
      bookedAt: json['bookedAt'] != null
          ? DateTime.parse(json['bookedAt'] as String)
          : DateTime.parse(json['scheduledAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labName': labName,
      'scheduledAt': scheduledAt.toIso8601String(),
      'testNames': testNames,
      'status': status,
      'location': location,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? labName,
    DateTime? scheduledAt,
    List<String>? testNames,
    String? status,
    String? location,
    DateTime? bookedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      labName: labName ?? this.labName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      testNames: testNames ?? this.testNames,
      status: status ?? this.status,
      location: location ?? this.location,
      bookedAt: bookedAt ?? this.bookedAt,
    );
  }
}
