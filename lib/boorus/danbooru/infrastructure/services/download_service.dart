// Dart imports:
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:ui';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';

// Project imports:
import 'package:boorusama/app_constants.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/domain/i_downloadable.dart';
import 'package:boorusama/core/infrastructure/IOHelper.dart';

class DownloadService implements IDownloadService {
  DownloadService();

  final ReceivePort _port = ReceivePort();
  bool _permissionReady = false;
  String _localPath = '';
  String _savedDir = '';

  @override
  void download(IDownloadable downloadable) async {
    await FlutterDownloader.enqueue(
        saveInPublicStorage: true,
        url: downloadable.downloadUrl,
        fileName: downloadable.fileName,
        savedDir: _savedDir,
        showNotification: true,
        openFileFromNotification: true);
  }

  Future<void> _prepare() async {
    //TODO: refactor to use configurable input
    final savedDir = io.Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    _savedDir = savedDir.path;
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
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
    _localPath = await IOHelper.getLocalPath(AppConstants.appName);
    _permissionReady = await IOHelper.checkPermission();
    final savedDir = io.Directory(_localPath);
    final bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      try {
        savedDir.create();
        _savedDir = savedDir.path;
      } catch (e) {
        _savedDir = await IOHelper.getLocalPathFallback();
      }
    }

    _prepare();
    // ignore: avoid_print
    print("Download service initialized");
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
