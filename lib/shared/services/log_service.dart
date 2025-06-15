import 'dart:convert';
import 'dart:typed_data';
import '../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/log_entry_model.dart';
import 'encryption_util.dart';

class LogService {
  final FlutterSecureStorage storage;
  final EncryptionUtil encryption;
  static const _key = 'dispatch_logs';

  LogService({FlutterSecureStorage? storage, EncryptionUtil? encryption})
      : storage = storage ?? const FlutterSecureStorage(),
        encryption = encryption ?? EncryptionUtil(defaultEncryptionKey);

  Future<void> addLog({
    required String user,
    required String phone,
    required String location,
    required bool success,
    required int attempts,
    String? failureCause,
  }) async {
    final existing = await storage.read(key: _key);
    List<LogEntry> logs = [];
    if (existing != null) {
      final bytes = encryption.decrypt(existing);
      final jsonStr = utf8.decode(bytes);
      final List list = jsonDecode(jsonStr) as List;
      logs = list
          .map((e) => LogEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    logs.add(
      LogEntry(
        timestamp: DateTime.now(),
        user: user,
        phone: phone,
        location: location,
        success: success,
        attempts: attempts,
        failureCause: failureCause,
      ),
    );
    final jsonStr = jsonEncode(
      logs.map((e) => e.toJson()).toList(growable: false),
    );
    final enc = encryption.encrypt(Uint8List.fromList(utf8.encode(jsonStr)));
    await storage.write(key: _key, value: enc);
  }

  Future<List<LogEntry>> getLogs() async {
    final existing = await storage.read(key: _key);
    if (existing == null) return [];
    final bytes = encryption.decrypt(existing);
    final jsonStr = utf8.decode(bytes);
    final List list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => LogEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}