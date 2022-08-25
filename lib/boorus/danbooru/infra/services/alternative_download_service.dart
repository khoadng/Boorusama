// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

class AlternativeDownloadService implements IDownloadService<Post> {
  AlternativeDownloadService({
    required FileNameGenerator fileNameGenerator,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  })  : _fileNameGenerator = fileNameGenerator,
        _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;

  final FileNameGenerator _fileNameGenerator;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void dispose() {}

  Future<void> _showNotification(
    Post post,
    String message,
    String fileName, {
    NotificationDetails? notificationDetails,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      post.id,
      fileName,
      message,
      notificationDetails,
      payload: fileName,
    );
  }

  @override
  Future<void> download(item, {String? path}) async {
    final dio = Dio();
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      item.id.toString(),
      item.id.toString(),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    final fileName = _fileNameGenerator.generateFor(item);

    try {
      await _showNotification(
        item,
        'in progress',
        fileName,
        notificationDetails: platformChannelSpecifics,
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

      await _showNotification(
        item,
        'completed',
        fileName,
        notificationDetails: platformChannelSpecifics,
      );
    } catch (e) {
      await _showNotification(
        item,
        'failed',
        fileName,
        notificationDetails: platformChannelSpecifics,
      );
    }
  }

  @override
  Future<void> init() async {}
}
