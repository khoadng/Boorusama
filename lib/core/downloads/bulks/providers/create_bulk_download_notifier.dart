// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../info/device_info.dart';
import '../../../search/histories/history.dart';
import '../../../settings/providers.dart';
import '../../../settings/settings.dart';
import '../types/download_options.dart';
import 'bulk_download_notifier.dart';

final createBulkDownloadInitialTagsProvider =
    Provider.autoDispose<List<String>?>((ref) => null);

final bulkDownloadQualityProvider = Provider.autoDispose<DownloadQuality>(
  (ref) => ref.watch(settingsProvider.select((e) => e.downloadQuality)),
  dependencies: [
    settingsProvider,
  ],
);

class CreateBulkDownload2Notifier extends AutoDisposeNotifier<DownloadOptions> {
  @override
  DownloadOptions build() {
    return DownloadOptions(
      path: '',
      notifications: true,
      skipIfExists: true,
      quality: ref.watch(bulkDownloadQualityProvider).name,
      perPage: 100,
      concurrency: 5,
      tags: ref.watch(createBulkDownloadInitialTagsProvider) ?? [],
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
    state = state.copyWith(
      path: path,
    );
  }

  void setNotifications(bool value) {
    state = state.copyWith(
      notifications: value,
    );
  }

  void setSkipIfExists(bool value) {
    state = state.copyWith(
      skipIfExists: value,
    );
  }

  void setQuality(String? quality) {
    state = state.copyWith(
      quality: quality,
    );
  }

  void setConcurrency(int value) {
    state = state.copyWith(
      concurrency: value,
    );
  }

  void start() {
    ref.read(bulkDownloadProvider.notifier).downloadFromOptions(state);
  }

  void startLater() {
    ref.read(bulkDownloadProvider.notifier).queueDownloadLater(state);
  }

  int? get androidSdkInt =>
      ref.read(deviceInfoProvider).androidDeviceInfo?.version.sdkInt;
}

final createBulkDownload2Provider =
    AutoDisposeNotifierProvider<CreateBulkDownload2Notifier, DownloadOptions>(
  CreateBulkDownload2Notifier.new,
);
