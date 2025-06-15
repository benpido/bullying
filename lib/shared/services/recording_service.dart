import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'encryption_util.dart';

class RecordingService {
  final AudioRecorder _record;
  final Duration duration;
  final Future<double?> Function(String path) _freeSpaceProvider;
  final EncryptionUtil _encryption;
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  RecordingService({
    AudioRecorder? recorder,
    this.duration = const Duration(seconds: 30),
    Future<double?> Function(String path)? freeSpaceProvider,
    EncryptionUtil? encryption,
  }) : _record = recorder ?? AudioRecorder(),
       _freeSpaceProvider =
           freeSpaceProvider ?? DiskSpacePlus().getFreeDiskSpaceForPath,
       _encryption =
           encryption ?? EncryptionUtil('default_secret_key_123456');

  static const double _requiredMb = 1.0;

  Future<String?> recordFor30Seconds({
    VoidCallback? onInsufficientStorage,
  }) async {
    if (await _record.isRecording()) return null;
    if (!await _record.hasPermission()) return null;

    final dir = await getTemporaryDirectory();
    final free = await _freeSpaceProvider(dir.path) ?? 0;
    if (free < _requiredMb) {
      onInsufficientStorage?.call();
      return null;
    }
    final path =
        '${dir.path}/emergency_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _record.start(
      path: path,
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
    );

    _isRecording = true;
    await Future.delayed(duration);
    if (await _record.isRecording()) {
      await _record.stop();
    }
    _isRecording = false;
    final bytes = await File(path).readAsBytes();
    await File(path).delete();
    return _encryption.encrypt(bytes);
  }
}