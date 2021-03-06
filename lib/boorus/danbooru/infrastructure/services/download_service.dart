// Dart imports:
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:ui';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/domain/i_downloadable.dart';
import 'package:boorusama/core/infrastructure/IOHelper.dart';

final downloadServiceProvider = Provider<IDownloadService>((ref) {
  final downloader = DownloadService();

  return downloader;
});

class DownloadService implements IDownloadService {
  DownloadService();

  ReceivePort _port = ReceivePort();
  bool _permissionReady;
  String _localPath;
  String _savedDir;

  @override
  void download(IDownloadable downloadable) async {
    final exist = await io.File(
            _savedDir + io.Platform.pathSeparator + downloadable.fileName)
        .exists();

    if (exist) return;

    await FlutterDownloader.enqueue(
        url: downloadable.downloadUrl,
        fileName: downloadable.fileName,
        savedDir: _savedDir,
        showNotification: true,
        openFileFromNotification: true);
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

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
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      // final task = _tasks?.firstWhere((task) => task.taskId == id);
      // if (task != null) {
      //   setState(() {
      //     task.status = status;
      //     task.progress = progress;
      //   });
      // }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Future<Null> init() async {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);

    _permissionReady = false;
    _localPath = await IOHelper.getLocalPath('Download');
    _permissionReady = await IOHelper.checkPermission();

    _prepare();
    print("Download service initialized");
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
  }
}
