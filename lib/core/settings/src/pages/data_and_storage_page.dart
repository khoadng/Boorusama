// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/caching/types.dart';
import '../../../../foundation/utils/file_utils.dart';
import '../../../bookmarks/providers.dart';
import '../../../cache/cache_notifier.dart';
import '../../../cache/providers.dart';
import '../../../widgets/settings_card.dart';
import '../../../widgets/widgets.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../types/settings.dart';
import '../widgets/settings_page_scaffold.dart';
import '../widgets/settings_tile.dart';
import '../widgets/storage_segment_bar.dart';

final diskSpaceProvider = Provider.autoDispose<(CacheSizeInfo, int)>((
  ref,
) {
  final appCache = ref.watch(appCacheSizeProvider);
  final imageCache = ref.watch(imageCacheSizeProvider);
  final tagCache = ref.watch(tagCacheSizeProvider);
  final diskSpace = ref.watch(diskSpaceInfoProvider);
  final videoCache = ref.watch(videoCacheSizeProvider);
  final bookmarkCache = ref.watch(bookmarkCacheInfoProvider);
  final persistentCache = ref.watch(persistentCacheSizeProvider);

  final cacheInfo = CacheSizeInfo(
    appCacheSize: appCache.valueOrNull ?? DirectorySizeInfo.zero,
    imageCacheSize: imageCache.valueOrNull ?? DirectorySizeInfo.zero,
    tagCacheSize: tagCache.valueOrNull ?? 0,
    diskSpaceInfo: diskSpace.valueOrNull ?? DiskSpaceInfo.zero,
    videoCacheSize: videoCache.valueOrNull ?? DirectorySizeInfo.zero,
    persistentCacheSize: persistentCache.valueOrNull ?? 0,
  );

  final bookmarkCacheSize = bookmarkCache.valueOrNull?.$1 ?? 0;

  return (cacheInfo, bookmarkCacheSize);
});

class DataAndStoragePage extends ConsumerStatefulWidget {
  const DataAndStoragePage({
    super.key,
  });

  @override
  ConsumerState<DataAndStoragePage> createState() => _DataAndStoragePageState();
}

class _DataAndStoragePageState extends ConsumerState<DataAndStoragePage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return SettingsPageScaffold(
      title: Text(context.t.settings.data_and_storage.data_and_storage),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      children: [
        _buildDiskSpace(),
        _buildCacheSection(settings, notifier),
        _buildDataSection(),
      ],
    );
  }

  Widget _buildDiskSpace() {
    final colorScheme = Theme.of(context).colorScheme;
    final (sizeInfo, bookmarkCacheSize) = ref.watch(diskSpaceProvider);
    final diskInfo = sizeInfo.diskSpaceInfo;

    final hasDiskData = diskInfo.totalSpace > 0;

    if (!hasDiskData) {
      return SettingsCard(
        title: context.t.settings.data_and_storage.storage,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: StorageSegmentBar(
            subtitle: context.t.settings.data_and_storage.loading,
            segments: _createStorageSegments(
              colorScheme: colorScheme,
              systemSize: 100,
              isPlaceholder: true,
            ),
            totalSpace: 100,
          ),
        ),
      );
    }

    final storageBreakdown = sizeInfo.getStorageBreakdown(
      bookmarkCacheSize: bookmarkCacheSize,
    );
    final segments = _mapToStorageSegments(
      storageBreakdown,
      sizeInfo,
      colorScheme,
    );

    return SettingsCard(
      title: context.t.settings.data_and_storage.storage,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: StorageSegmentBar(
          subtitle: context.t.settings.data_and_storage.disk_space.status_title(
            freeSpace: Filesize.parse(diskInfo.freeSpace),
            totalSpace: Filesize.parse(diskInfo.totalSpace),
          ),
          segments: segments,
          totalSpace: diskInfo.totalSpace,
        ),
      ),
    );
  }

  List<StorageSegment> _createStorageSegments({
    required ColorScheme colorScheme,
    int systemSize = 0,
    int imagesSize = 0,
    int videosSize = 0,
    int othersSize = 0,
    int freeSize = 0,
    bool isPlaceholder = false,
  }) {
    return [
      if (systemSize > 0 || isPlaceholder)
        StorageSegment(
          name: context.t.settings.data_and_storage.disk_space.groups.system,
          size: systemSize,
          color: isPlaceholder
              ? colorScheme.surfaceContainer
              : colorScheme.surface,
          subtitle: isPlaceholder ? '---' : Filesize.parse(systemSize),
        ),
      if (imagesSize > 0 || isPlaceholder)
        StorageSegment(
          name: context.t.settings.data_and_storage.disk_space.groups.images,
          size: imagesSize,
          color: const Color(0xFFFF6B35),
          subtitle: isPlaceholder ? '---' : Filesize.parse(imagesSize),
        ),
      if (videosSize > 0 || isPlaceholder)
        StorageSegment(
          name: context.t.settings.data_and_storage.disk_space.groups.videos,
          size: videosSize,
          color: const Color(0xFF007AFF),
          subtitle: isPlaceholder ? '---' : Filesize.parse(videosSize),
        ),
      if (othersSize > 0 || isPlaceholder)
        StorageSegment(
          name: context.t.settings.data_and_storage.disk_space.groups.others,
          size: othersSize,
          color: const Color(0xFF30D158),
          subtitle: isPlaceholder ? '---' : Filesize.parse(othersSize),
        ),
      if (freeSize > 0 || isPlaceholder)
        StorageSegment(
          name: context.t.settings.data_and_storage.disk_space.groups.free,
          size: freeSize,
          color: colorScheme.surfaceContainer,
          subtitle: isPlaceholder ? '---' : Filesize.parse(freeSize),
        ),
    ];
  }

  List<StorageSegment> _mapToStorageSegments(
    List<StorageInfo> storageBreakdown,
    CacheSizeInfo sizeInfo,
    ColorScheme colorScheme,
  ) {
    var systemDataSize = 0;
    var imagesSize = 0;
    var videosSize = 0;
    var othersSize = 0;
    var freeSpaceSize = 0;

    // Calculate grouped sizes
    for (final info in storageBreakdown) {
      switch (info.type) {
        case StorageType.systemData:
          systemDataSize += info.size;
        case StorageType.imageCache:
        case StorageType.bookmarkImages:
          imagesSize += info.size;
        case StorageType.videoCache:
          videosSize += info.size;
        case StorageType.tagCache:
        case StorageType.appCache:
          othersSize += info.size;
        case StorageType.freeSpace:
          freeSpaceSize += info.size;
      }
    }

    return _createStorageSegments(
      colorScheme: colorScheme,
      systemSize: systemDataSize,
      imagesSize: imagesSize,
      videosSize: videosSize,
      othersSize: othersSize,
      freeSize: freeSpaceSize,
    );
  }

  Widget _buildCacheSection(
    Settings settings,
    SettingsNotifier notifier,
  ) {
    return SettingsCard(
      title: context.t.settings.data_and_storage.cache,
      child: Column(
        children: [
          _buildImageCacheItem(),
          const Divider(height: 1),
          _buildVideoCacheItem(),
          const Divider(height: 1),
          _buildTagCacheItem(),
          const Divider(height: 1),
          _buildAllCacheItem(),
          const Divider(height: 1),
          BooruSwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            value: settings.clearImageCacheOnStartup,
            title: Text(
              context.t.settings.data_and_storage.clear_cache_on_start_up,
            ),
            onChanged: (value) => notifier.updateSettings(
              settings.copyWith(clearImageCacheOnStartup: value),
            ),
          ),
          const Divider(height: 1),
          _buildVideoCacheMaxSizeItem(settings, notifier),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return SettingsCard(
      title: context.t.settings.data_and_storage.data,
      child: _buildBookmarkImageDataItem(),
    );
  }

  Widget _buildImageCacheItem() {
    final imageCacheAsync = ref.watch(imageCacheSizeProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(context.t.settings.data_and_storage.image_only_cache),
      subtitle: imageCacheAsync.when(
        data: (imageCacheSize) => Text(
          context.t.settings.performance.cache_size_info
              .replaceAll(
                '{0}',
                Filesize.parse(imageCacheSize.size),
              )
              .replaceAll(
                '{1}',
                imageCacheSize.fileCount.toString(),
              ),
        ),
        loading: () => Text(context.t.settings.data_and_storage.loading),
        error: (_, _) =>
            Text(context.t.settings.data_and_storage.error_loading_cache_info),
      ),
      trailing: FilledButton(
        onPressed: imageCacheAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAppImageCache(),
        child: Text(context.t.settings.performance.clear_cache),
      ),
    );
  }

  Widget _buildVideoCacheItem() {
    final cacheSizeAsync = ref.watch(videoCacheSizeProvider);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(context.t.settings.data_and_storage.video_cache),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(
          context.t.settings.performance.cache_size_info
              .replaceAll(
                '{0}',
                Filesize.parse(sizeInfo.size),
              )
              .replaceAll(
                '{1}',
                sizeInfo.fileCount.toString(),
              ),
        ),
        loading: () => Text(context.t.settings.data_and_storage.loading),
        error: (_, _) =>
            Text(context.t.settings.data_and_storage.error_loading_cache_info),
      ),
      trailing: FilledButton(
        onPressed: cacheSizeAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAppVideoCache(),
        child: Text(context.t.settings.performance.clear_cache),
      ),
    );
  }

  Widget _buildTagCacheItem() {
    final tagCacheAsync = ref.watch(tagCacheSizeProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(context.t.settings.data_and_storage.tag_cache),
      subtitle: tagCacheAsync.when(
        data: (tagCacheSize) => Text(Filesize.parse(tagCacheSize)),
        loading: () => Text(context.t.settings.data_and_storage.loading),
        error: (_, _) =>
            Text(context.t.settings.data_and_storage.error_loading_cache_info),
      ),
      trailing: FilledButton(
        onPressed: tagCacheAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAppTagCache(),
        child: Text(context.t.settings.performance.clear_cache),
      ),
    );
  }

  Widget _buildAllCacheItem() {
    final cacheSizeAsync = ref.watch(cacheSizeProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(context.t.settings.data_and_storage.all_cache),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(Filesize.parse(sizeInfo.totalSize)),
        loading: () => Text(context.t.settings.data_and_storage.loading),
        error: (_, _) =>
            Text(context.t.settings.data_and_storage.error_loading_cache_info),
      ),
      trailing: FilledButton(
        onPressed: cacheSizeAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAllCache(),
        child: Text(context.t.settings.performance.clear_cache),
      ),
    );
  }

  Widget _buildBookmarkImageDataItem() {
    final cacheInfo = ref.watch(bookmarkCacheInfoProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(context.t.settings.data_and_storage.bookmark_images),
      subtitle: cacheInfo.when(
        data: (data) => Text(
          Filesize.parse(data.$1),
        ),
        loading: () => Text(context.t.settings.data_and_storage.loading),
        error: (_, _) =>
            Text(context.t.settings.data_and_storage.error_loading_cache_info),
      ),
      trailing: FilledButton(
        onPressed: cacheInfo.isLoading
            ? null
            : () {
                ref.read(bookmarkImageCacheManagerProvider).clearAllCache();
                ref.invalidate(bookmarkCacheInfoProvider);
              },
        child: Text(context.t.settings.performance.clear_cache),
      ),
    );
  }

  Widget _buildVideoCacheMaxSizeItem(
    Settings settings,
    SettingsNotifier notifier,
  ) {
    final options = _getVideoCacheMaxSizeOptions();
    final currentValue = settings.videoCacheMaxSize;
    final selectedOption =
        options.firstWhereOrNull(
          (option) => option == currentValue,
        ) ??
        CacheSize.oneGigabyte;

    return SettingsTile(
      title: Text(context.t.settings.data_and_storage.video_cache_limit),
      subtitle: Text(
        context.t.settings.data_and_storage.video_cache_limit_description,
      ),
      selectedOption: selectedOption,
      items: options,
      onChanged: (option) => notifier.updateSettings(
        settings.copyWith(videoCacheMaxSize: option),
      ),
      optionBuilder: (option) => Text(_getCacheSizeLabel(context, option)),
    );
  }

  List<CacheSize> _getVideoCacheMaxSizeOptions() => [
    CacheSize.oneHundredMegabytes,
    CacheSize.fiveHundredMegabytes,
    CacheSize.oneGigabyte,
    CacheSize.twoGigabytes,
    CacheSize.fiveGigabytes,
    CacheSize.tenGigabytes,
    CacheSize.zero,
  ];

  String _getCacheSizeLabel(BuildContext context, CacheSize cacheSize) =>
      switch (cacheSize) {
        CacheSize.zero => context.t.settings.data_and_storage.no_limit,
        _ => cacheSize.displayString(withSpace: true),
      };
}
