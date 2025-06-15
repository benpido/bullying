class LogEntry {
  final DateTime timestamp;
  final String user;
  final String phone;
  final String location;
  final bool success;
  final int attempts;
  final String? failureCause;

  LogEntry({
    required this.timestamp,
    required this.user,
    required this.phone,
    required this.location,
    required this.success,
    required this.attempts,
    this.failureCause,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
        'user': user,
        'phone': phone,
        'location': location,
        'success': success,
        'attempts': attempts,
        'failureCause': failureCause,
      };

  static LogEntry fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      user: json['user'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      success: json['success'] as bool,
      attempts: json['attempts'] as int,
      failureCause: json['failureCause'] as String?,
    );
  }
}