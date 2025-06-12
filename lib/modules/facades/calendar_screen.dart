import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/routes/app_routes.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _events = {};
  final TextEditingController _eventController = TextEditingController();
  int _secretTapCount = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _loadSavedEvents();
  }

  Future<void> _loadSavedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      final Map<String, dynamic> decoded = json.decode(eventsJson);
      setState(() {
        _events.clear();
        decoded.forEach((key, value) {
          final date = DateTime.parse(key);
          _events[date] = List<String>.from(value);
        });
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = _events.map(
      (key, value) => MapEntry(key.toIso8601String(), value),
    );
    await prefs.setString('events', json.encode(encoded));
  }

  List<String> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  void _addEvent(DateTime day) {
    if (_eventController.text.isNotEmpty) {
      final dateKey = DateTime(day.year, day.month, day.day);
      setState(() {
        _events.putIfAbsent(dateKey, () => []).add(_eventController.text);
        _eventController.clear();
      });
      _saveEvents();
    }
  }

  void _editEvent(DateTime date, int index) async {
    final controller = TextEditingController(text: _events[date]![index]);
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar evento'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _events[date]![index] = controller.text;
                  });
                  _saveEvents();
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _deleteEvent(DateTime date, int index) {
    setState(() {
      _events[date]?.removeAt(index);
    });
    _saveEvents();
  }

  void _handleSecretTap(DateTime day) {
    if (day.day == 13) {
      _secretTapCount++;
      if (_secretTapCount >= 5) {
        _secretTapCount = 0;
        Navigator.pushNamed(context, AppRoutes.emergency);
      }
    } else {
      _secretTapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Engrenagem (sem AppBar)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.config);
                    },
                  ),
                ],
              ),

              GestureDetector(
                // Detecta toque fora do calendário para desmarcar o dia selecionado
                onTap: () {
                  setState(() {
                    _selectedDay = null; // Desmarcar o dia
                  });
                },
                child: TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _handleSecretTap(selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_selectedDay != null)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _eventController,
                        decoration: const InputDecoration(
                          labelText: 'Añadir Evento',
                          border: UnderlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addEvent(_selectedDay!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addEvent(_selectedDay!),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              if (_selectedDay != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getEventsForDay(_selectedDay!).length,
                  itemBuilder: (context, index) {
                    final event = _getEventsForDay(_selectedDay!)[index];
                    return ListTile(
                      title: Text(event),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _editEvent(
                                  DateTime(
                                    _selectedDay!.year,
                                    _selectedDay!.month,
                                    _selectedDay!.day,
                                  ),
                                  index,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed:
                                () => _deleteEvent(
                                  DateTime(
                                    _selectedDay!.year,
                                    _selectedDay!.month,
                                    _selectedDay!.day,
                                  ),
                                  index,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
