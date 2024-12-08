// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'package:boorusama/core/http/providers.dart';
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
