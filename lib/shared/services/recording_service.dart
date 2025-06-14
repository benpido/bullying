import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecordingService {
  final AudioRecorder _record;
  final Duration duration;

  RecordingService({AudioRecorder? recorder, this.duration = const Duration(seconds: 30)})
      : _record = recorder ?? AudioRecorder();

  Future<void> recordFor30Seconds() async {
    if (await _record.isRecording()) return;
    if (!await _record.hasPermission()) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/emergency_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _record.start(
      path: path,
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
    );

    await Future.delayed(duration);
    if (await _record.isRecording()) {
      await _record.stop();
    }
  }
}