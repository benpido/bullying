import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bullying/shared/services/log_service.dart';
import 'package:bullying/shared/models/log_entry_model.dart';

class FakeStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String?> map = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => map[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    map[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    map.remove(key);
  }
}

class FakeConnectivity extends Fake implements Connectivity {
  ConnectivityResult result;
  FakeConnectivity(this.result);
  @override
  Future<ConnectivityResult> checkConnectivity() async => result;
}

class StreamConnectivity extends Fake implements Connectivity {
  ConnectivityResult result;
  final StreamController<ConnectivityResult> controller =
      StreamController<ConnectivityResult>.broadcast();
  StreamConnectivity(this.result);
  @override
  Future<ConnectivityResult> checkConnectivity() async => result;

  @override
  Stream<ConnectivityResult> get onConnectivityChanged => controller.stream;

  void emit(ConnectivityResult r) {
    result = r;
    controller.add(r);
  }

  Future<void> dispose() async => controller.close();
}

class FakeLocation extends Fake implements Location {
  LocationData data;
  FakeLocation(this.data);
  @override
  Future<LocationData> getLocation() async => data;
  @override
  Future<PermissionStatus> hasPermission() async => PermissionStatus.granted;
  @override
  Future<PermissionStatus> requestPermission() async =>
      PermissionStatus.granted;
}

class FakeLogService extends Fake implements LogService {
  final List<LogEntry> logs = [];

  @override
  Future<void> addLog({
    required String user,
    required String phone,
    required String location,
    required bool success,
    required int attempts,
    String? failureCause,
  }) async {
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
  }

  @override
  Future<List<LogEntry>> getLogs() async => logs;
}