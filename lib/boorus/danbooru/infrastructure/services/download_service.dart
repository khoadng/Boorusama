// Dart imports:
import 'dart:isolate';
import 'dart:ui';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';

// Project imports:
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/domain/i_downloadable.dart';
import 'package:boorusama/core/infrastructure/io_helper.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService implements IDownloadService {
  DownloadService();

  final ReceivePort _port = ReceivePort();
  bool _permissionReady = false;
  String _savedDir = '';

  @override
  Future<void> download(
    IDownloadable downloadable, {
    String? path,
  }) async {
    //TODO: display a toast or snack and redirect to permission settings.
    _permissionReady = await IOHelper.checkPermission();

    if (!_permissionReady) {
      return;
    }

    await FlutterDownloader.enqueue(
      saveInPublicStorage: true,
      url: downloadable.downloadUrl,
      fileName: downloadable.fileName,
      savedDir: _savedDir,
    );
  }

  Future<void> _prepare() async {
    // This won't be used.
    _savedDir = (await getTemporaryDirectory()).path;
  }

  void _bindBackgroundIsolate() {
    final bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Future<void> init() async {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);

    _permissionReady = false;

    await _prepare();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
  }
}
