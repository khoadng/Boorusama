// Dart imports:
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/infra/device_info_service.dart';

class DownloadData {
  const DownloadData(
    this.postId,
    this.path,
    this.fileName,
  );

  final int postId;
  final String path;
  final String fileName;
}

class BulkDownloader {
  BulkDownloader({
    required FileNameGenerator<Post> fileNameGenerator,
    required this.deviceInfo,
  }) : _fileNameGenerator = fileNameGenerator;

  final FileNameGenerator<Post> _fileNameGenerator;
  final DeviceInfo deviceInfo;
  final ReceivePort _port = ReceivePort();
  final Map<String, DownloadData> _taskIdToPostIdMap = {};

  final _eventController = StreamController<dynamic>.broadcast();
  final compositeSubscription = CompositeSubscription();

  Future<void> enqueueDownload(
    Post downloadable, {
    String? path,
    required String folderName,
  }) async {
    final fileName = _fileNameGenerator.generateFor(downloadable);
    final tempDir = await getApplicationSupportDirectory();

    final id = await FlutterDownloader.enqueue(
      showNotification: false,
      url: downloadable.downloadUrl,
      fileName: fileName,
      savedDir: tempDir.path,
    );

    if (id != null) {
      _taskIdToPostIdMap[id] = DownloadData(
        downloadable.id,
        '${tempDir.path}/$fileName',
        fileName,
      );
    }
  }

  Future<void> cancelAll() => FlutterDownloader.cancelAll();

  Stream<DownloadData> get stream => _eventController.stream
      .map((data) {
        final String id = data[0];
        final DownloadTaskStatus status = data[1];
        // final int progress = data[2];

        return Tuple2(id, status);
      })
      .where((event) => event.item2 == DownloadTaskStatus.complete)
      .map((event) => _taskIdToPostIdMap[event.item1]!);

  // ignore: no-empty-block
  Future<void> _prepare() async {
    // This won't be used.
    // _savedDir = (await getTemporaryDirectory()).path;
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

  Future<void> init() async {
    _bindBackgroundIsolate();
    await FlutterDownloader.registerCallback(downloadCallback);
    await _prepare();

    _port.listen(_eventController.add).addTo(compositeSubscription);
  }

  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void dispose() {
    _unbindBackgroundIsolate();
    _eventController.close();
    compositeSubscription.dispose();
  }
}
