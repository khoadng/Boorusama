// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../debug/providers.dart';
import 'data.dart';

final protectionLogRecorderProvider = Provider<ProtectionLogRecorder>((ref) {
  final recorder = ProtectionLogRecorder(ref.watch(appLoggerProvider));
  ref.onDispose(recorder.dispose);
  return recorder;
});
