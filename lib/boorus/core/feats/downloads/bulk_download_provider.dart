// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
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

final bulkDownloadProvider = Provider<BulkDownloader>((ref) {
  final userAgentGenerator = ref.watch(userAgentGeneratorProvider);

  return CrossplatformBulkDownloader(userAgentGenerator);
});

final bulkDownloadDataProvider = StreamProvider<BulkDownloadStatus>(
    (ref) => ref.watch(bulkDownloadProvider).stream);

final bulkDownloaderManagerProvider =
    NotifierProvider<BulkDownloadManagerNotifier, void>(
  BulkDownloadManagerNotifier.new,
  dependencies: [
    bulkDownloadFileNameProvider,
    postRepoProvider,
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

final bulkDownloadFileNameProvider = Provider<FileNameGenerator<Post>>((ref) {
  throw UnimplementedError();
});

final bulkDownloadStateProvider =
    NotifierProvider<BulkDownloadStateNotifier, BulkDownloadState>(
  BulkDownloadStateNotifier.new,
);
