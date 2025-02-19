// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../info/device_info.dart';
import '../../../search/histories/history.dart';
import '../types/download_options.dart';

class CreateDownloadOptionsNotifier
    extends AutoDisposeFamilyNotifier<DownloadOptions, DownloadOptions> {
  @override
  DownloadOptions build(DownloadOptions arg) {
    return DownloadOptions(
      path: arg.path,
      notifications: arg.notifications,
      skipIfExists: arg.skipIfExists,
      quality: arg.quality,
      perPage: arg.perPage,
      concurrency: arg.concurrency,
      tags: arg.tags,
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
      tags: state.tags.clone()..addTag(tag),
    );
  }

  void addTags(List<String> tags) {
    state = state.copyWith(
      tags: state.tags.clone()..addTags(tags),
    );
  }

  void removeTag(String tag) {
    state = state.copyWith(
      tags: state.tags.clone()..removeTagString(tag),
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

  int? get androidSdkInt =>
      ref.read(deviceInfoProvider).androidDeviceInfo?.version.sdkInt;
}

final createDownloadOptionsProvider = NotifierProvider.autoDispose
    .family<CreateDownloadOptionsNotifier, DownloadOptions, DownloadOptions>(
  CreateDownloadOptionsNotifier.new,
);
