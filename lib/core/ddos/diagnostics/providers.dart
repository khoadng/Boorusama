import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../debug/providers.dart';
import 'data.dart';

final protectionLogRecorderProvider = Provider<ProtectionLogRecorder>((ref) {
  final recorder = ProtectionLogRecorder(ref.watch(appLoggerProvider));
  ref.onDispose(recorder.dispose);
  return recorder;
});
