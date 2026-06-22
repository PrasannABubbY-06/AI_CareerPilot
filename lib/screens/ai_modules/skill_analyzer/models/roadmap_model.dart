class RoadmapModel {

  final String module;

  final String description;

  final int hours;

  final String priority;

  final bool completed;

  const RoadmapModel({
    required this.module,
    required this.description,
    required this.hours,
    required this.priority,
    this.completed = false,
  });

  // ==========================
  // FROM JSON
  // ==========================

  factory RoadmapModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RoadmapModel(
      module: json["module"] ?? "",
      description:
          json["description"] ?? "",
      hours: json["hours"] ?? 0,
      priority:
          json["priority"] ?? "Medium",
      completed:
          json["completed"] ?? false,
    );
  }

  // ==========================
  // TO JSON
  // ==========================

  Map<String, dynamic> toJson() {
    return {
      "module": module,
      "description": description,
      "hours": hours,
      "priority": priority,
      "completed": completed,
    };
  }

  // ==========================
  // COPY WITH
  // ==========================

  RoadmapModel copyWith({
    String? module,
    String? description,
    int? hours,
    String? priority,
    bool? completed,
  }) {
    return RoadmapModel(
      module: module ?? this.module,
      description:
          description ??
          this.description,
      hours: hours ?? this.hours,
      priority:
          priority ?? this.priority,
      completed:
          completed ?? this.completed,
    );
  }

  @override
  String toString() {
    return '''
RoadmapModel(
 module: $module,
 description: $description,
 hours: $hours,
 priority: $priority,
 completed: $completed
)
''';
  }
}
