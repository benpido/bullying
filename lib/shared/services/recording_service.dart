import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecordingService {
  final Record _record = Record();

  Future<void> recordFor30Seconds() async {
    if (!await _record.hasPermission()) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/emergency_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _record.start(
      path: path,
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      samplingRate: 44100,
    );

    await Future.delayed(const Duration(seconds: 30));
    await _record.stop();
  }
}