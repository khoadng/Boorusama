// Dart imports:
import 'dart:isolate';
import 'dart:ui';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/core/application/download/download_service.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/infra/device_info_service.dart';
import 'package:boorusama/core/infra/io_helper.dart';
import 'package:boorusama/core/infra/services/alternative_download_service.dart';
import 'package:boorusama/core/infra/services/macos_download_service.dart';
import 'package:boorusama/core/infra/services/windows_download_service.dart';

// ignore: avoid_bool_literals_in_conditional_expressions
bool _shouldUsePublicStorage(DeviceInfo deviceInfo) => isAndroid()
    ? hasScopedStorage(deviceInfo.androidDeviceInfo?.version.sdkInt) ?? true
    : false;

Future<String> _getSaveDir(DeviceInfo deviceInfo, String defaultPath) async {
  if (isIOS()) return IOHelper.getDownloadPath();

  return hasScopedStorage(deviceInfo.androidDeviceInfo?.version.sdkInt) ?? true
      ? defaultPath
      : await IOHelper.getDownloadPath();
}

Future<DownloadService<Post>> createDownloader(
  DownloadMethod method,
  DeviceInfo deviceInfo,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  UserAgentGenerator agentGenerator,
) async {
  if (isMobilePlatform()) {
    if (method == DownloadMethod.imageGallerySaver) {
      final d = AlternativeDownloadService(
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        agentGenerator: agentGenerator,
      );
      await d.init();

      return d;
    }

    final d = DownloadServiceFlutterDownloader(
      deviceInfo: deviceInfo,
    );

    if (isAndroid() || isIOS()) {
      await FlutterDownloader.initialize();
    }

    await d.init();

    return d;
  } else {
    final d = isMacOS()
        ? MacOSDownloader(agentGenerator)
        : WindowDownloader(agentGenerator);

    await d.init();

    return d;
  }
}

@pragma('vm:entry-point')
class DownloadServiceFlutterDownloader implements DownloadService<Post> {
  DownloadServiceFlutterDownloader({
    required this.deviceInfo,
  });

  final DeviceInfo deviceInfo;
  final ReceivePort _port = ReceivePort();
  String _savedDir = '';

  @override
  Future<void> download(
    downloadable, {
    String? path,
    String? folderName,
    required FileNameGenerator fileNameGenerator,
  }) async {
    final fileName = fileNameGenerator.generateFor(downloadable);
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
    send!.send([id, status.value, progress]);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
  }
}
