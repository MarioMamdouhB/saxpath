class AnalyticsEvent {
  const AnalyticsEvent({
    required this.eventId,
    required this.eventName,
    required this.dayNumber,
    required this.taskId,
    required this.attemptId,
    required this.metadata,
    required this.createdAt,
  });

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      eventId: json['event_id'] as String,
      eventName: json['event_name'] as String,
      dayNumber: json['day_number'] as int?,
      taskId: json['task_id'] as String?,
      attemptId: json['attempt_id'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, value)),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String eventId;
  final String eventName;
  final int? dayNumber;
  final String? taskId;
  final String? attemptId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
}
