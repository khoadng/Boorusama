// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/platform.dart';

final bulkDownloadThumbnailsProvider =
    StateProvider<Map<String, String>>((ref) {
  return {};
});

final bulkDownloadFileSizeProvider = StateProvider<Map<String, int>>((ref) {
  return {};
});

final bulkDownloadSelectedTagsProvider =
    NotifierProvider<BulkDownloadTagsNotifier, List<String>>(
  BulkDownloadTagsNotifier.new,
);

final isValidToStartDownloadProvider = Provider.autoDispose<bool>(
  (ref) {
    final selectedTags = ref.watch(bulkDownloadSelectedTagsProvider);
    final downloadOptions = ref.watch(bulkDownloadOptionsProvider);

    if (isAndroid()) {
      final hasScopeStorage = hasScopedStorage(
              ref.read(deviceInfoProvider).androidDeviceInfo?.version.sdkInt) ??
          false;

      return selectedTags.isNotEmpty &&
          downloadOptions.isValidDownload(hasScopeStorage: hasScopeStorage);
    } else {
      return selectedTags.isNotEmpty && downloadOptions.storagePath.isNotEmpty;
    }
  },
);

final bulkDownloadOptionsProvider = StateProvider<DownloadOptions>((ref) {
  return const DownloadOptions(
    onlyDownloadNewFile: true,
    storagePath: '',
  );
});

final bulkDownloadProvider =
    Provider.family<BulkDownloader, BooruConfig>((ref, config) {
  return CrossplatformBulkDownloader(
    userAgentGenerator: ref.watch(userAgentGeneratorProvider(config)),
    logger: ref.watch(loggerProvider),
  );
});

final bulkDownloadDataProvider =
    StreamProvider.family<BulkDownloadStatus, BooruConfig>(
        (ref, config) => ref.watch(bulkDownloadProvider(config)).stream);

final bulkDownloaderManagerProvider =
    NotifierProvider.family<BulkDownloadManagerNotifier, void, BooruConfig>(
  BulkDownloadManagerNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final bulkDownloadManagerStatusProvider =
    StateProvider<BulkDownloadManagerStatus>((ref) {
  ref.listen(
    bulkDownloadSelectedTagsProvider,
    (previous, next) {
      if (previous == null) return;
      if (previous.isEmpty && next.isNotEmpty) {
        ref.controller.state = BulkDownloadManagerStatus.dataSelected;
      }
    },
  );

  return BulkDownloadManagerStatus.initial;
});

final bulkDownloadFileNameProvider =
    Provider.family<FileNameGenerator<Post>, BooruConfig>((ref, config) {
  if (config.booruType.isDanbooruBased) {
    return BoorusamaStyledFileNameGenerator();
  }

  if (config.booruType.isE621Based || config.booruType.isGelbooruBased) {
    return Md5OnlyFileNameGenerator();
  }

  return DownloadUrlBaseNameFileNameGenerator();
});

final bulkDownloadStateProvider = NotifierProvider.family<
    BulkDownloadStateNotifier, BulkDownloadState, BooruConfig>(
  BulkDownloadStateNotifier.new,
);
