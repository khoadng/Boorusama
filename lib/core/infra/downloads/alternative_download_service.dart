// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/infra/io_helper.dart';
import 'package:boorusama/core/platform.dart';

class AlternativeDownloadService implements DownloadService<Post> {
  AlternativeDownloadService({
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    required UserAgentGenerator agentGenerator,
    this.enableNotification = true,
  })  : _agentGenerator = agentGenerator,
        _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final bool enableNotification;
  final UserAgentGenerator _agentGenerator;

  @override
  // ignore: no-empty-block
  void dispose() {}

  Future<String> getDownloadDirPath() async => isAndroid()
      ? (await IOHelper.getDownloadPath())
      : (await getApplicationDocumentsDirectory()).path;

  @override
  Future<void> download(
    item, {
    String? path,
    String? folderName,
    required FileNameGenerator fileNameGenerator,
  }) async {
    final dio = Dio();
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      item.id.toString(),
      item.id.toString(),
      playSound: false,
      enableVibration: false,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(
        presentSound: false,
      ),
    );
    final fileName = fileNameGenerator.generateFor(item);

    try {
      if (enableNotification) {
        await _flutterLocalNotificationsPlugin.show(
          item.id,
          fileName,
          'in progress',
          platformChannelSpecifics,
        );
      }

      final savedPath = folderName ?? await getDownloadDirPath();
      final filePath = '$savedPath/$fileName';

      await dio.download(
        item.downloadUrl,
        filePath,
        options: Options(
          headers: {
            'User-Agent': _agentGenerator.generate(),
          },
        ),
      );

      if (isAndroid()) {
        MediaScanner.loadMedia(path: filePath);
      }

      if (enableNotification) {
        await _flutterLocalNotificationsPlugin.show(
          item.id,
          fileName,
          'completed',
          platformChannelSpecifics,
          payload: fileName,
        );
      }
    } catch (e) {
      await _flutterLocalNotificationsPlugin.show(
        item.id,
        fileName,
        'failed',
        platformChannelSpecifics,
        payload: fileName,
      );
    }
  }

  @override
  // ignore: no-empty-block, avoid-redundant-async
  Future<void> init() async {}
}
