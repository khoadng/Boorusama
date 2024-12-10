// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../configs/config.dart';
import '../../configs/current.dart';
import '../../http/providers.dart';
import '../../settings/data.dart';
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
