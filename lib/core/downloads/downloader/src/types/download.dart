// Project imports:
import 'options.dart';
import 'result.dart';

export 'result.dart';
export 'options.dart';
export 'error.dart';

abstract class DownloadService {
  Future<DownloadResult> download(DownloadOptions options);

  Future<bool> cancelAll(String group);

  Future<void> pauseAll(String group);

  Future<void> resumeAll(String group);
}
