import 'package:background_downloader/background_downloader.dart' as bg;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:boorusama/core/download_manager/providers.dart';

/// Publishes realistic platform updates through the production event ingress.
final class DownloadEventDriver {
  DownloadEventDriver(this.container);

  final ProviderContainer container;
  final events = <bg.TaskUpdate>[];

  void status(
    bg.DownloadTask task,
    bg.TaskStatus status, {
    bg.TaskException? exception,
  }) => publish(bg.TaskStatusUpdate(task, status, exception));

  void progress(
    bg.DownloadTask task,
    double progress, {
    int expectedFileSize = 4096,
  }) => publish(bg.TaskProgressUpdate(task, progress, expectedFileSize));

  void publish(bg.TaskUpdate update) {
    events.add(update);
    container.read(downloadTaskEventIngressProvider).publish(update);
  }
}
