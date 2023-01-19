// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

// Project imports:
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts/post.dart';

class AlternativeDownloadService implements DownloadService<Post> {
  AlternativeDownloadService({
    required FileNameGenerator fileNameGenerator,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    this.enableNotification = true,
  })  : _fileNameGenerator = fileNameGenerator,
        _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;

  final FileNameGenerator _fileNameGenerator;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final bool enableNotification;

  @override
  // ignore: no-empty-block
  void dispose() {}

  @override
  Future<void> download(
    item, {
    String? path,
    String? folderName,
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
    final fileName = _fileNameGenerator.generateFor(item);

    try {
      if (enableNotification) {
        await _flutterLocalNotificationsPlugin.show(
          item.id,
          fileName,
          'in progress',
          platformChannelSpecifics,
        );
      }

      final response = await dio.get(
        item.downloadUrl,
        options: Options(
          headers: {
            'User-Agent': userAgent,
          },
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        name: fileName,
      );

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
