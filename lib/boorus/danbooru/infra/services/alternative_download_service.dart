// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/application/download/download_service.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

class AlternativeDownloadService implements DownloadService<Post> {
  AlternativeDownloadService({
    required FileNameGenerator fileNameGenerator,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  })  : _fileNameGenerator = fileNameGenerator,
        _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;

  final FileNameGenerator _fileNameGenerator;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void dispose() {}

  @override
  Future<void> download(item, {String? path}) async {
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
      await _flutterLocalNotificationsPlugin.show(
        item.id,
        fileName,
        'in progress',
        platformChannelSpecifics,
      );

      final response = await dio.get(
        item.downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        name: fileName,
      );

      await _flutterLocalNotificationsPlugin.show(
        item.id,
        fileName,
        'completed',
        platformChannelSpecifics,
        payload: fileName,
      );
      await _flutterLocalNotificationsPlugin.show(
        item.id,
        fileName,
        'completed',
        payload: fileName,
        const NotificationDetails(
            android: AndroidNotificationDetails(
          'completed',
          'completed',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
          enableVibration: false,
        )),
      );
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
  Future<void> init() async {}
}
