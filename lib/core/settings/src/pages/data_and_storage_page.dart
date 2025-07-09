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
      title: Text(context.t.settings.data_and_storage.data_and_storage),
      children: [
        const SettingsHeader(label: 'Cache'),
        _buildImageCache(cacheSizeAsync),
        _buildTagCache(cacheSizeAsync),
        _buildAllCache(cacheSizeAsync),
        SwitchListTile(
          value: settings.clearImageCacheOnStartup,
          title: Text(
            context.t.settings.data_and_storage.clear_cache_on_start_up,
          ),
          onChanged: (value) => notifier.updateSettings(
            settings.copyWith(clearImageCacheOnStartup: value),
          ),
        ),
        const Divider(),
        SettingsHeader(label: 'Data'.hc),
        _buildBookmarkImageData(cacheSizeAsync.isLoading),
      ],
    );
  }

  Widget _buildBookmarkImageData(bool isLoadingCache) {
    final cacheInfo = ref.watch(bookmarkCacheInfoProvider);

    return ListTile(
      title: Text('Bookmark images'.hc),
      subtitle: cacheInfo.when(
        data: (data) => Text(
          Filesize.parse(data.$1),
        ),
        loading: () => Text('Loading...'.hc),
        error: (_, _) => Text('Error loading cache info'.hc),
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

  Widget _buildAllCache(AsyncValue<CacheSizeInfo> cacheSizeAsync) {
    return ListTile(
      title: Text('All cache'.hc),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(Filesize.parse(sizeInfo.totalSize)),
        loading: () => Text('Loading...'.hc),
        error: (_, _) => Text('Error loading cache info'.hc),
      ),
      trailing: FilledButton(
        onPressed: cacheSizeAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAllCache(),
        child: Text(context.t.settings.performance.clear_cache),
      ),
    );
  }

  Widget _buildTagCache(AsyncValue<CacheSizeInfo> cacheSizeAsync) {
    return ListTile(
      title: Text('Tag cache'.hc),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(Filesize.parse(sizeInfo.tagCacheSize)),
        loading: () => Text('Loading...'.hc),
        error: (_, _) => Text('Error loading cache info'.hc),
      ),
      trailing: FilledButton(
        onPressed: cacheSizeAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAppTagCache(),
        child: Text(context.t.settings.performance.clear_cache),
      ),
    );
  }

  Widget _buildImageCache(AsyncValue<CacheSizeInfo> cacheSizeAsync) {
    return ListTile(
      title: Text('Image only cache'.hc),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(
          context.t.settings.performance.cache_size_info
              .replaceAll(
                '{0}',
                Filesize.parse(sizeInfo.imageCacheSize.size),
              )
              .replaceAll(
                '{1}',
                sizeInfo.imageCacheSize.fileCount.toString(),
              ),
        ),
        loading: () => Text('Loading...'.hc),
        error: (_, _) => Text('Error loading cache info'.hc),
      ),
      trailing: FilledButton(
        onPressed: cacheSizeAsync.isLoading
            ? null
            : () => ref.read(cacheSizeProvider.notifier).clearAppImageCache(),
        child: Text(context.t.settings.performance.clear_cache),
      ),
    );
  }
}
