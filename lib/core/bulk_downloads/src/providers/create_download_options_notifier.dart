// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../info/device_info.dart';
import '../../../search/histories/history.dart';
import '../../../search/selected_tags/tag.dart';
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
      blacklistedTags: arg.blacklistedTags,
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

  void addBlacklistedTag(String tag) {
    final currentTags = queryAsList(state.blacklistedTags);

    final newTags = [...currentTags, tag];

    state = state.copyWith(
      blacklistedTags: () => jsonEncode(newTags),
    );
  }

  void removeBlacklistedTag(String tag) {
    final currentTags = queryAsList(state.blacklistedTags);

    final newTags = currentTags.where((t) => t != tag).toList();

    state = state.copyWith(
      blacklistedTags: () => jsonEncode(newTags),
    );
  }

  int? get androidSdkInt =>
      ref.read(deviceInfoProvider).androidDeviceInfo?.version.sdkInt;
}

final createDownloadOptionsProvider = NotifierProvider.autoDispose
    .family<CreateDownloadOptionsNotifier, DownloadOptions, DownloadOptions>(
  CreateDownloadOptionsNotifier.new,
);
