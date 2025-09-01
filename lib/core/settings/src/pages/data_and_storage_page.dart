// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../bookmarks/providers.dart';
import '../../../cache/providers.dart';
import '../../../widgets/widgets.dart';
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
        SettingsHeader(label: context.t.settings.data_and_storage.cache),
        _buildImageCache(cacheSizeAsync),
        _buildTagCache(cacheSizeAsync),
        _buildAllCache(cacheSizeAsync),
        BooruSwitchListTile(
          value: settings.clearImageCacheOnStartup,
          title: Text(
            context.t.settings.data_and_storage.clear_cache_on_start_up,
          ),
          onChanged: (value) => notifier.updateSettings(
            settings.copyWith(clearImageCacheOnStartup: value),
          ),
        ),
        const Divider(),
        SettingsHeader(label: context.t.settings.data_and_storage.data),
        _buildBookmarkImageData(cacheSizeAsync.isLoading),
      ],
    );
  }

  Widget _buildBookmarkImageData(bool isLoadingCache) {
    final cacheInfo = ref.watch(bookmarkCacheInfoProvider);

    return ListTile(
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

  Widget _buildAllCache(AsyncValue<CacheSizeInfo> cacheSizeAsync) {
    return ListTile(
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

  Widget _buildTagCache(AsyncValue<CacheSizeInfo> cacheSizeAsync) {
    return ListTile(
      title: Text(context.t.settings.data_and_storage.tag_cache),
      subtitle: cacheSizeAsync.when(
        data: (sizeInfo) => Text(Filesize.parse(sizeInfo.tagCacheSize)),
        loading: () => Text(context.t.settings.data_and_storage.loading),
        error: (_, _) =>
            Text(context.t.settings.data_and_storage.error_loading_cache_info),
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
      title: Text(context.t.settings.data_and_storage.image_only_cache),
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
        loading: () => Text(context.t.settings.data_and_storage.loading),
        error: (_, _) =>
            Text(context.t.settings.data_and_storage.error_loading_cache_info),
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
