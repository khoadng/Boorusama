// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/infra/device_info_service.dart';
import 'package:boorusama/core/platform.dart';
import 'alternative_download_service.dart';
import 'download_service_flutter_downloader.dart';
import 'macos_download_service.dart';
import 'windows_download_service.dart';

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
