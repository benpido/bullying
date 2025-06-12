import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/event_model.dart';

class EventService {
  static const String _eventsKey = 'events';

  Future<void> saveEvents(Map<DateTime, List<String>> eventsMap) async {
    final prefs = await SharedPreferences.getInstance();

    // Flatten the map into a list of EventModel
    List<EventModel> allEvents = [];
    for (var entry in eventsMap.entries) {
      for (var desc in entry.value) {
        allEvents.add(EventModel(date: entry.key, description: desc));
      }
    }

    final List<String> jsonList =
        allEvents.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_eventsKey, jsonList);
  }

  Future<Map<DateTime, List<String>>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_eventsKey);

    Map<DateTime, List<String>> eventsMap = {};

    if (jsonList != null) {
      for (var jsonStr in jsonList) {
        final Map<String, dynamic> jsonObj = json.decode(jsonStr);
        final event = EventModel.fromJson(jsonObj);
        final dateKey = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );
        eventsMap.putIfAbsent(dateKey, () => []).add(event.description);
      }
    }

    return eventsMap;
  }
}
