class LogEntry {
  final DateTime timestamp;
  final String location;
  final bool success;

  LogEntry({
    required this.timestamp,
    required this.location,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'location': location,
    'success': success,
  };

  static LogEntry fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String,
      success: json['success'] as bool,
    );
  }
}