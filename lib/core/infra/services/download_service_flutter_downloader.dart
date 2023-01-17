// Dart imports:
import 'dart:isolate';
import 'dart:ui';

// Package imports:
import 'package:boorusama/core/infra/services/macos_download_service.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/core/application/download/download_service.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/infra/device_info_service.dart';
import 'package:boorusama/core/infra/io_helper.dart';
import 'package:boorusama/core/infra/services/alternative_download_service.dart';
import 'package:boorusama/core/infra/services/windows_download_service.dart';

bool _shouldUsePublicStorage(DeviceInfo deviceInfo) =>
    hasScopedStorage(deviceInfo);

Future<String> _getSaveDir(DeviceInfo deviceInfo, String defaultPath) async =>
    hasScopedStorage(deviceInfo)
        ? defaultPath
        : await IOHelper.getDownloadPath();

Future<DownloadService<Post>> createDownloader(
  DownloadMethod method,
  FileNameGenerator fileNameGenerator,
  DeviceInfo deviceInfo,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
) async {
  if (isMobilePlatform()) {
    if (method == DownloadMethod.imageGallerySaver) {
      final d = AlternativeDownloadService(
        fileNameGenerator: fileNameGenerator,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      );
      await d.init();

      return d;
    }

    final d = DownloadServiceFlutterDownloader(
      fileNameGenerator: fileNameGenerator,
      deviceInfo: deviceInfo,
    );

    if (isAndroid() || isIOS()) {
      await FlutterDownloader.initialize();
    }

    await d.init();

    return d;
  } else {
    final d = isMacOS()
        ? MacOSDownloader(fileNameGenerator)
        : WindowDownloader(fileNameGenerator);

    await d.init();

    return d;
  }
}

@pragma('vm:entry-point')
class DownloadServiceFlutterDownloader implements DownloadService<Post> {
  DownloadServiceFlutterDownloader({
    required FileNameGenerator fileNameGenerator,
    required this.deviceInfo,
  }) : _fileNameGenerator = fileNameGenerator;

  final FileNameGenerator _fileNameGenerator;
  final DeviceInfo deviceInfo;
  final ReceivePort _port = ReceivePort();
  String _savedDir = '';

  @override
  Future<void> download(
    downloadable, {
    String? path,
    String? folderName,
  }) async {
    final fileName = _fileNameGenerator.generateFor(downloadable);
    await FlutterDownloader.enqueue(
      saveInPublicStorage: _shouldUsePublicStorage(deviceInfo),
      url: downloadable.downloadUrl,
      fileName: fileName,
      savedDir: await _getSaveDir(deviceInfo, _savedDir),
    );
  }

  Future<void> _prepare() async {
    // This won't be used.
    _savedDir = (await getTemporaryDirectory()).path;
  }

  void _bindBackgroundIsolate() {
    final bool isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
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
    await FlutterDownloader.registerCallback(downloadCallback);
    await _prepare();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
  }
}
