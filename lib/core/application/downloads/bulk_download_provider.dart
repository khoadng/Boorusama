// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/android.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/downloads.dart';
import 'package:boorusama/core/provider.dart';

final bulkDownloadThumbnailsProvider =
    StateProvider<Map<String, String>>((ref) {
  return {};
});

final bulkDownloadSelectedTagsProvider =
    NotifierProvider.autoDispose<SelectedTagsNotifier, List<TagSearchItem>>(
        SelectedTagsNotifier.new,
        dependencies: [
      tagInfoProvider,
    ]);

final isValidToStartDownloadProvider = Provider.autoDispose<bool>(
  (ref) {
    final selectedTags = ref.watch(bulkDownloadSelectedTagsProvider);
    final downloadOptions = ref.watch(bulkDownloadOptionsProvider);
    final hasScopeStorage = hasScopedStorage(
            ref.read(deviceInfoProvider).androidDeviceInfo?.version.sdkInt) ??
        false;

    return selectedTags.isNotEmpty &&
        downloadOptions.isValidDownload(hasScopeStorage: hasScopeStorage);
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

final bulkdDownloadDataProvider = StreamProvider<BulkDownloadStatus>(
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
  return BulkDownloadManagerStatus.initial;
});

final bulkDownloadFileNameProvider = Provider<FileNameGenerator<Post>>((ref) {
  throw UnimplementedError();
});

final bulkDownloadStateProvider =
    NotifierProvider<BulkDownloadStateNotifier, BulkDownloadState>(
  BulkDownloadStateNotifier.new,
);
