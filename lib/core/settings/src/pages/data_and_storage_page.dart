// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../bookmarks/providers.dart';
import '../../../cache/providers.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_page_scaffold.dart';

final bookmarkCacheInfoProvider = FutureProvider.autoDispose<(int, int)>((
  ref,
) async {
  final cacheManager = ref.watch(bookmarkImageCacheManagerProvider);
  return cacheManager.getCacheStats();
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
    final cacheSizeAsync = ref.watch(cacheSizeProvider);

    return SettingsPageScaffold(
      title: const Text('settings.data_and_storage.data_and_storage').tr(),
      children: [
        const SettingsHeader(label: 'Cache'),
        _buildImageCache(cacheSizeAsync),
        _buildTagCache(cacheSizeAsync),
        _buildAllCache(cacheSizeAsync),
        SwitchListTile(
          value: settings.clearImageCacheOnStartup,
          title: const Text(
            'settings.data_and_storage.clear_cache_on_start_up',
          ).tr(),
          onChanged: (value) => notifier.updateSettings(
            settings.copyWith(clearImageCacheOnStartup: value),
          ),
        ),
        const Divider(),
        const SettingsHeader(label: 'Data'),
        _buildBookmarkImageData(cacheSizeAsync.isLoading),
      ],
    );
  }

  Widget _buildBookmarkImageData(bool isLoadingCache) {
    final cacheInfo = ref.watch(bookmarkCacheInfoProvider);

    return ListTile(
      title: const Text('Bookmark images'),
      subtitle: cacheInfo.when(
        data: (data) => Text(
          Filesize.parse(data.$1),
        ),
        loading: () => const Text('Loading...'),
        error: (_, _) => const Text('Error loading cache info'),
      ),
      trailing: FilledButton(
        onPressed: cacheInfo.isLoading
            ? null
            : () {
                ref.read(bookmarkImageCacheManagerProvider).clearAllCache();
                ref.invalidate(bookmarkCacheInfoProvider);
              },
        child: const Text('settings.performance.clear_cache').tr(),
      ),
    );
  }

  Widget _buildAllCache(AsyncValue<CacheSizeInfo> cacheSizeAsync) {
    return ListTile(
      title: const Text('All cache'),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(Filesize.parse(sizeInfo.totalSize)),
        loading: () => const Text('Loading...'),
        error: (_, _) => const Text('Error loading cache info'),
      ),
      trailing: FilledButton(
        onPressed: cacheSizeAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAllCache(),
        child: const Text('settings.performance.clear_cache').tr(),
      ),
    );
  }

  Widget _buildTagCache(AsyncValue<CacheSizeInfo> cacheSizeAsync) {
    return ListTile(
      title: const Text('Tag cache'),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(Filesize.parse(sizeInfo.tagCacheSize)),
        loading: () => const Text('Loading...'),
        error: (_, _) => const Text('Error loading cache info'),
      ),
      trailing: FilledButton(
        onPressed: cacheSizeAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAppTagCache(),
        child: const Text('settings.performance.clear_cache').tr(),
      ),
    );
  }

  Widget _buildImageCache(AsyncValue<CacheSizeInfo> cacheSizeAsync) {
    return ListTile(
      title: const Text('Image only cache'),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(
          'settings.performance.cache_size_info'
              .tr()
              .replaceAll(
                '{0}',
                Filesize.parse(sizeInfo.imageCacheSize.size),
              )
              .replaceAll(
                '{1}',
                sizeInfo.imageCacheSize.fileCount.toString(),
              ),
        ),
        loading: () => const Text('Loading...'),
        error: (_, _) => const Text('Error loading cache info'),
      ),
      trailing: FilledButton(
        onPressed: cacheSizeAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAppImageCache(),
        child: const Text('settings.performance.clear_cache').tr(),
      ),
    );
  }
}
