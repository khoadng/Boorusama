// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';

class CrossplatformBulkDownloader<T> extends BulkDownloader<T> {
  late final String Function(T item) _urlResolver;
  late final String Function(T item) _fileNameResolver;
  late final int Function(T item) _idResolver;
  late final DownloadManager _downloadManager;
  final StreamController<DownloadData> _downloadDataController =
      StreamController.broadcast();

  CrossplatformBulkDownloader({
    required String Function(T item) urlResolver,
    required String Function(T item) fileNameResolver,
    required int Function(T items) idResolver,
    required UserAgentGenerator userAgentGenerator,
  }) {
    _urlResolver = urlResolver;
    _fileNameResolver = fileNameResolver;
    _idResolver = idResolver;
    _downloadManager = DownloadManager(
        dio: Dio(BaseOptions(headers: {
      'User-Agent': userAgentGenerator.generate(),
    })));
  }

  @override
  Future<void> init() async {
    // You can perform any initialization logic here if needed.
  }

  @override
  void dispose() {
    _downloadDataController.close();
  }

  @override
  Future<String> getDownloadDirPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  @override
  Future<void> enqueueDownload(T downloadable, {String? folder}) async {
    String url = _urlResolver(downloadable);
    String fileName = _fileNameResolver(downloadable);
    String downloadDir = await getDownloadDirPath();
    String savePath = folder != null ? join(downloadDir, folder) : downloadDir;

    final task =
        await _downloadManager.addDownload(url, join(savePath, fileName));

    // Add a listener for download completion
    task?.whenDownloadComplete().then((_) {
      _downloadDataController.add(DownloadData(
        _idResolver(downloadable),
        task.request.path,
        task.request.url,
      ));
    }).catchError((error) {
      _downloadDataController
          .addError(error); // Emit error events through the stream
    });
    ;
  }

  @override
  Future<void> cancelAll() async {
    List<String> urls = _downloadManager
        .getAllDownloads()
        .map((task) => task.request.url)
        .toList();
    await _downloadManager.cancelBatchDownloads(urls);
  }

  @override
  Stream<DownloadData> get stream {
    return _downloadDataController.stream;
  }

  @override
  bool get isInit {
    // Check if the downloader is initialized.
    // Since there's no specific initialization in this implementation, we return true.
    return true;
  }
}
