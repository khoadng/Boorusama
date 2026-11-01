// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../download_manager/providers.dart';
import '../../../../download_manager/types.dart';
import '../../../background/types.dart';
import '../types/pending_downloads.dart';

final pendingDownloadsProvider = Provider<PendingDownloads>(
  (ref) => PendingDownloads(
    isActive: (url) => ref
        .read(downloadTaskUpdatesProvider)
        .all(FileDownloader.defaultGroup)
        .any(
          (update) =>
              update.task.url == url &&
              switch (update) {
                TaskStatusUpdate(:final status) => !status.isFinalState,
                TaskProgressUpdate() => true,
              },
        ),
  ),
);
