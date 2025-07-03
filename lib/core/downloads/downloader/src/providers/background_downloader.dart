// Dart imports:
import 'dart:async';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../ddos_solver/types.dart';
import '../../../path/directory.dart';
import '../types/download.dart';
import '../types/metadata.dart';
import 'file_downloader_ex.dart';

class BackgroundDownloader implements DownloadService {
  @override
  DownloadTaskInfoOrError download({
    required String url,
    required String filename,
    DownloaderMetadata? metadata,
    int? fileSize,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) =>
      TaskEither.Do(
        ($) async {
          final downloadDirTask = await tryGetDownloadDirectory().run();
          final downloadDir = downloadDirTask.fold((l) => null, (r) => r);

          final task = DownloadTask(
            url: url,
            filename: filename,
            allowPause: true,
            retries: 1,
            baseDirectory: downloadDir != null
                ? BaseDirectory.root
                : BaseDirectory.applicationDocuments,
            directory: downloadDir != null ? downloadDir.path : '',
            updates: Updates.statusAndProgress,
            metaData: metadata?.toJsonString() ?? '',
            headers: headers,
            group: metadata?.group ?? FileDownloader.defaultGroup,
          );

          return FileDownloader().enqueueIfNeeded(
            task,
            skipIfExists: skipIfExists,
          );
        },
      );

  @override
  DownloadTaskInfoOrError downloadCustomLocation({
    required String url,
    required String path,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) =>
      TaskEither.Do(
        ($) async {
          final task = DownloadTask(
            url: url,
            filename: filename,
            baseDirectory: BaseDirectory.root,
            directory: path,
            allowPause: true,
            retries: 1,
            updates: Updates.statusAndProgress,
            metaData: metadata?.toJsonString() ?? '',
            headers: headers,
            group: metadata?.group ?? FileDownloader.defaultGroup,
          );

          return FileDownloader().enqueueIfNeeded(
            task,
            skipIfExists: skipIfExists,
          );
        },
      );

  @override
  Future<bool> cancelAll(String group) {
    return FileDownloader().cancelAll(group: group);
  }

  @override
  Future<void> pauseAll(String group) {
    return FileDownloader().pauseAll(group: group);
  }

  @override
  Future<void> resumeAll(String group) {
    return FileDownloader().resumeAll(group: group);
  }
}

class TaskResponseAdapter implements HttpResponse {
  const TaskResponseAdapter(
    this._update,
    this.statusCode,
    this.data,
  );

  final TaskStatusUpdate _update;

  @override
  final int? statusCode;
  @override
  final dynamic data;
  @override
  Uri get requestUri => Uri.tryParse(_update.task.url) ?? Uri();
  @override
  Map<String, dynamic> get headers => Map<String, dynamic>.from(
        _update.responseHeaders ?? <String, String>{},
      );
}

class TaskErrorAdapter implements HttpError {
  const TaskErrorAdapter(this._update);
  final TaskStatusUpdate _update;

  @override
  HttpResponse get response {
    final statusCode = switch (_update.exception) {
      final TaskHttpException e => e.httpResponseCode,
      _ => null,
    };

    final body = switch (_update.exception) {
      final TaskHttpException e => e.description,
      _ => null,
    };

    return TaskResponseAdapter(
      _update,
      statusCode,
      body,
    );
  }

  @override
  Uri get requestUri => Uri.tryParse(_update.task.url) ?? Uri();
  @override
  String? get message => _update.exception?.description;
}
