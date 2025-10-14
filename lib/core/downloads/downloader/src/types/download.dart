// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../foundation/path.dart';
import '../../../../configs/config/types.dart';
import '../../../../settings/types.dart';
import 'error.dart';
import 'metadata.dart';

typedef DownloadTaskInfoOrError = TaskEither<DownloadError, DownloadTaskInfo>;

class DownloadTaskInfo extends Equatable {
  const DownloadTaskInfo({
    required this.path,
    required this.id,
  });

  final String path;
  final String id;

  @override
  List<Object?> get props => [path, id];
}

abstract class DownloadService {
  DownloadTaskInfoOrError download({
    required String url,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  });

  DownloadTaskInfoOrError downloadCustomLocation({
    required String url,
    required String path,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  });

  Future<bool> cancelAll(String group);

  Future<void> pauseAll(String group);

  Future<void> resumeAll(String group);
}

extension DownloadWithSettingsX on DownloadService {
  DownloadTaskInfoOrError downloadWithSettings(
    Settings settings, {
    required String url,
    required String filename,
    required BooruConfigDownload config,
    required Map<String, String>? headers,
    DownloaderMetadata? metadata,
    String? folderName,
    String? path,
  }) {
    final downloadPath =
        path ??
        (config.hasCustomDownloadLocation
            ? config.location
            : settings.downloadPath);

    return downloadPath != null && downloadPath.isNotEmpty
        ? downloadCustomLocation(
            url: url,
            metadata: metadata,
            path: join(downloadPath, folderName),
            filename: filename,
            skipIfExists:
                settings.downloadFileExistedBehavior.skipDownloadIfExists,
            headers: headers,
          )
        : download(
            url: url,
            metadata: metadata,
            filename: filename,
            skipIfExists:
                settings.downloadFileExistedBehavior.skipDownloadIfExists,
            headers: headers,
          );
  }
}

String removeFileExtension(String url) {
  final lastDotIndex = url.lastIndexOf('.');
  if (lastDotIndex != -1) {
    return url.substring(0, lastDotIndex);
  } else {
    // If there is no '.', return the original URL
    return url;
  }
}

extension BooruConfigDownloadX on BooruConfigDownload {
  bool get hasCustomDownloadLocation =>
      location != null && location!.isNotEmpty;
}
