// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../providers/download_notifier.dart';
import '../types/download.dart';

final downloadServiceProvider = Provider<DownloadService>(
  (ref) => const WebDownloadService(),
);

final downloadMultipleFileCheckProvider =
    Provider.family<MultipleFileDownloadCheck, BooruConfigAuth>(
      (ref, config) =>
          () => config.booruType.canDownloadMultipleFiles,
    );

class WebDownloadService implements DownloadService {
  const WebDownloadService();

  @override
  Future<bool> cancelAll(String group) {
    return Future.value(false);
  }

  @override
  Future<DownloadResult> download(DownloadOptions options) {
    return Future.value(
      DownloadFailure(
        GenericDownloadError(
          savedPath: none(),
          fileName: options.filename,
          message: 'Downloading is not supported on web',
        ),
      ),
    );
  }

  @override
  Future<void> pauseAll(String group) {
    return Future.value();
  }

  @override
  Future<void> resumeAll(String group) {
    return Future.value();
  }
}
