// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/platform.dart';

class CreateBulkDownloadNotifier extends AutoDisposeNotifier<BulkDownloadTask> {
  @override
  BulkDownloadTask build() {
    return BulkDownloadTask.randomId(
      tags: ref.watch(createBulkDownloadInitialProvider) ?? [],
      path: '',
    );
  }

  void addFromSearchHistory(SearchHistory history) {
    if (history.queryType == QueryType.list) {
      final tags = history.queryAsList();
      addTags(tags);
    } else {
      addTag(history.query);
    }
  }

  void addTag(String tag) {
    state = state.copyWith(
      tags: {
        ...state.tags,
        tag,
      }.toList(),
    );
  }

  void addTags(List<String> tags) {
    state = state.copyWith(
      tags: {
        ...state.tags,
        ...tags,
      }.toList(),
    );
  }

  void removeTag(String tag) {
    state = state.copyWith(
      tags: [
        ...state.tags.where((e) => e != tag),
      ],
    );
  }

  void setPath(String path) {
    state = state.copyWith(path: path);
  }

  void setOptions(BulkDownloadOptions options) {
    state = state.copyWith(options: options);
  }

  bool start() {
    if (!state.valid(androidSdkInt: androidSdkInt)) return false;

    // check if there is any running task
    final runningTask = ref.read(bulkdownloadProvider).firstWhereOrNull(
          (e) => e.status == BulkDownloadTaskStatus.inProgress,
        );

    if (runningTask != null) {
      // check if it is completed
      final completed =
          ref.read(downloadTasksProvider).allCompleted(runningTask.id);

      if (!completed) {
        const msg =
            'Please wait for the current download to finish first before starting another one';

        ref.read(bulkDownloadErrorNotificationQueueProvider.notifier).state =
            msg;

        return false;
      }
    }

    final notifier = ref.read(bulkdownloadProvider.notifier);
    notifier.addTask(state);
    notifier.startTask(state.id);

    return true;
  }

  int? get androidSdkInt =>
      ref.read(deviceInfoProvider).androidDeviceInfo?.version.sdkInt;

  void queue() {
    if (!state.valid(androidSdkInt: androidSdkInt)) return;

    final notifier = ref.read(bulkdownloadProvider.notifier);
    notifier.addTask(state);
  }
}

extension BulkDownloadTaskXX on BulkDownloadTask {
  bool valid({
    int? androidSdkInt,
  }) {
    if (tags.isEmpty) return false;
    if (path.isEmpty) return false;

    if (!isAndroid()) return true;

    return !shouldDisplayWarning(
      hasScopeStorage: hasScopedStorage(androidSdkInt) ?? true,
    );
  }
}
