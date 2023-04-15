// Dart imports:
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/device_info_service.dart';

@pragma('vm:entry-point')
class DownloadServiceFlutterDownloader implements DownloadService<Post> {
  DownloadServiceFlutterDownloader({
    required this.deviceInfo,
  });

  final DeviceInfo deviceInfo;
  final ReceivePort _port = ReceivePort();
  final _eventController = StreamController<dynamic>.broadcast();
  final compositeSubscription = CompositeSubscription();
  final Map<String, String> _taskIdToFolderMap = {};

  @override
  Future<void> download(
    downloadable, {
    String? path,
    String? folderName,
    required FileNameGenerator fileNameGenerator,
  }) async {
    final fileName = fileNameGenerator.generateFor(downloadable);

    final id = await FlutterDownloader.enqueue(
      saveInPublicStorage: folderName == null,
      showNotification: false,
      url: downloadable.downloadUrl,
      fileName: fileName,
      savedDir: folderName ?? '',
    );

    if (id != null) {
      _taskIdToFolderMap[id] = '$folderName/$fileName';
    }
  }

  Future<void> _prepare() async {}

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

    _port.listen(_eventController.add).addTo(compositeSubscription);

    _eventController.stream
        .map((data) {
          final String id = data[0];
          final int status = data[1];
          // final int progress = data[2];

          return Tuple2(id, status);
        })
        .where((event) => event.item2 == DownloadTaskStatus.complete.value)
        .where((event) => _taskIdToFolderMap.containsKey(event.item1))
        .map((event) => _taskIdToFolderMap[event.item1]!)
        .listen((event) {
          if (isAndroid()) {
            MediaScanner.loadMedia(path: event);
          }
        })
        .addTo(compositeSubscription);
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
    compositeSubscription.dispose();
  }
}
