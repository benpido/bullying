import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/contact_model.dart';
import 'contact_service.dart';

typedef MessageSender = Future<void> Function(String number, String message);

class EmergencyDispatchService {
  final ContactService contactService;
  final Location location;
  final FlutterSecureStorage storage;
  final MessageSender sender;
  final Connectivity connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;

  EmergencyDispatchService({
    ContactService? contactService,
    Location? location,
    FlutterSecureStorage? storage,
    Connectivity? connectivity,
    required this.sender,
  }) : contactService = contactService ?? ContactService(),
       location = location ?? Location(),
       storage = storage ?? const FlutterSecureStorage(),
       connectivity = connectivity ?? Connectivity();

  Future<void> dispatch(String audioPath) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? 'NO DISPONIBLE';
    final phone = prefs.getString('userPhoneNumber') ?? 'NO DISPONIBLE';

    String locationStr = 'NO DISPONIBLE';
    try {
      final locData = await location.getLocation();
      locationStr = '${locData.latitude},${locData.longitude}';
    } catch (_) {}

    final now = DateTime.now().toIso8601String();
    final message =
        'Nombre: $name\nTeléfono: $phone\n'
        'Ubicación: $locationStr\nAudio: $audioPath\nFecha: $now';

    final contacts = await contactService.getContacts();

    final hasConnection =
        await connectivity.checkConnectivity() != ConnectivityResult.none;
    if (hasConnection) {
      for (final ContactModel c in contacts) {
        await sender(c.phoneNumber, message);
      }
      await _sendPending();
    } else {
      await _storePending(contacts.map((c) => c.phoneNumber).toList(), message);
    }
  }

  Future<void> _storePending(List<String> numbers, String message) async {
    final existing = await storage.read(key: 'pending');
    final List<dynamic> list = existing == null
        ? []
        : jsonDecode(existing) as List<dynamic>;
    list.add({'numbers': numbers, 'message': message});
    await storage.write(key: 'pending', value: jsonEncode(list));
  }

  Future<void> _sendPending() async {
    final pendingStr = await storage.read(key: 'pending');
    if (pendingStr == null) return;
    final List<dynamic> list = jsonDecode(pendingStr) as List<dynamic>;
    for (final item in list) {
      final message = item['message'] as String;
      final numbers = List<String>.from(item['numbers'] as List);
      for (final n in numbers) {
        await sender(n, message);
      }
    }
    await storage.delete(key: 'pending');
  }

  void startConnectivityMonitor() {
    _subscription?.cancel();
    _subscription = connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _sendPending();
      }
    });
    connectivity.checkConnectivity().then((result) {
      if (result != ConnectivityResult.none) {
        _sendPending();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}