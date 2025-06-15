import 'dart:convert';
import 'log_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/contact_model.dart';
import 'contact_service.dart';
import 'dart:typed_data';
import 'encryption_util.dart';
import 'notification_service.dart';
import '../constants.dart';

typedef MessageSender = Future<void> Function(String number, String message);

class EmergencyDispatchService {
  final ContactService contactService;
  final Location location;
  final FlutterSecureStorage storage;
  final MessageSender sender;
  final Connectivity connectivity;
  final LogService logService;
  final EncryptionUtil encryption;
  final NotificationService? notificationService;
  StreamSubscription<ConnectivityResult>? _subscription;

  EmergencyDispatchService({
    ContactService? contactService,
    Location? location,
    FlutterSecureStorage? storage,
    Connectivity? connectivity,
    LogService? logService,
    EncryptionUtil? encryption,
    this.notificationService,
    required this.sender,
  }) : contactService = contactService ?? ContactService(),
       location = location ?? Location(),
       storage = storage ?? const FlutterSecureStorage(),
       connectivity = connectivity ?? Connectivity(),
       logService = logService ?? LogService(),
       encryption = encryption ?? EncryptionUtil(defaultEncryptionKey);

  Future<void> dispatch(String audioData) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? 'NO DISPONIBLE';
    final phone = prefs.getString('userPhoneNumber') ?? 'NO DISPONIBLE';

    String locationStr = 'NO DISPONIBLE';
    try {
      var permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
      }
      if (permission == PermissionStatus.granted ||
          permission == PermissionStatus.grantedLimited) {
        final locData = await location.getLocation();
        locationStr = '${locData.latitude},${locData.longitude}';
      }
    } catch (_) {}

    final now = DateTime.now().toIso8601String();
    final message =
        'Nombre: $name\nTeléfono: $phone\n'
        'Ubicación: $locationStr\nAudio: $audioData\nFecha: $now';

    final contacts = await contactService.getContacts();
    final attempts = contacts.length;

    final hasConnection =
        await connectivity.checkConnectivity() != ConnectivityResult.none;
    if (hasConnection) {
      for (final ContactModel c in contacts) {
        await sender(c.phoneNumber, message);
      }
      await _sendPending();
      await logService.addLog(
        user: name,
        phone: phone,
        location: locationStr,
        success: true,
        attempts: attempts,
      );
    } else {
      await _storePending(contacts.map((c) => c.phoneNumber).toList(), message);
      await logService.addLog(
        user: name,
        phone: phone,
        location: locationStr,
        success: false,
        attempts: attempts,
        failureCause: 'offline',
      );
      await notificationService?.showDispatchFailureNotification();
    }
  }

  Future<void> _storePending(List<String> numbers, String message) async {
    final existing = await storage.read(key: 'pending');
    final List<dynamic> list = existing == null
        ? []
        : jsonDecode(existing) as List<dynamic>;
    final enc = encryption.encrypt(Uint8List.fromList(utf8.encode(message)));
    list.add({'numbers': numbers, 'message': enc});
    await storage.write(key: 'pending', value: jsonEncode(list));
  }

  Future<void> _sendPending() async {
    final pendingStr = await storage.read(key: 'pending');
    if (pendingStr == null) return;
    final List<dynamic> list = jsonDecode(pendingStr) as List<dynamic>;
    for (final item in list) {
      final encMsg = item['message'] as String;
      final bytes = encryption.decrypt(encMsg);
      final message = utf8.decode(bytes);
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