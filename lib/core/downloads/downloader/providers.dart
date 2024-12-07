// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/settings/data.dart';
import '../notifications/providers.dart';
import 'background_downloader.dart';
import 'download_service.dart';

final downloadServiceProvider =
    Provider.family<DownloadService, BooruConfigAuth>(
  (ref, config) {
    return BackgroundDownloader();
  },
  dependencies: [
    dioProvider,
    downloadNotificationProvider,
    currentBooruConfigProvider,
    settingsProvider,
  ],
);
