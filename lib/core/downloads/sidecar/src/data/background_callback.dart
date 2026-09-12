import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../downloader/types.dart';
import 'providers.dart';
import 'sidecar_store.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundSidecarFinished(TaskStatusUpdate update) async {
  if (DownloaderMetadata.fromJsonString(update.task.metaData).sidecarId ==
      null) {
    return;
  }
  // The headless isolate has no access to the application's provider scope.
  final container = ProviderContainer();
  try {
    final store = await container.read(sidecarStoreProvider.future);
    await finishDownloadSidecar(update, store: store);
  } finally {
    container.dispose();
  }
}

Future<void> finishDownloadSidecar(
  TaskStatusUpdate update, {
  required SidecarStore store,
}) async {
  final id = DownloaderMetadata.fromJsonString(update.task.metaData).sidecarId;
  if (id == null) return;
  switch (update.status) {
    case TaskStatus.complete:
      await store.complete(id, await update.task.filePath());
    case TaskStatus.canceled:
      await store.discard(id);
    case TaskStatus.enqueued:
    case TaskStatus.running:
    case TaskStatus.failed:
    case TaskStatus.notFound:
    case TaskStatus.waitingToRetry:
    case TaskStatus.paused:
      break; // Failed downloads can be retried with the original snapshot.
  }
}
