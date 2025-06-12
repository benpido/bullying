class EventModel {
  final DateTime date;
  final String description;

  EventModel({required this.date, required this.description});

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'description': description};
  }

  static EventModel fromJson(Map<String, dynamic> json) {
    return EventModel(
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
