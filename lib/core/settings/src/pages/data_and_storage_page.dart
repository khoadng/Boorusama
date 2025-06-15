// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../bookmarks/providers.dart';
import '../../../cache/providers.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_page_scaffold.dart';

final bookmarkCacheInfoProvider =
    FutureProvider.autoDispose<(int, int)>((ref) async {
  final cacheManager = ref.read(bookmarkImageCacheManagerProvider);
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

    return SettingsPageScaffold(
      title: const Text('settings.data_and_storage.data_and_storage').tr(),
      children: [
        const SettingsHeader(label: 'Cache'),
        Builder(
          builder: (context) {
            final sizeInfo = ref.watch(cacheSizeProvider);
            final imageCacheSize = sizeInfo.imageCacheSize;

            return ListTile(
              title: const Text('Image only cache'),
              subtitle: Text(
                'settings.performance.cache_size_info'
                    .tr()
                    .replaceAll('{0}', Filesize.parse(imageCacheSize.size))
                    .replaceAll('{1}', imageCacheSize.fileCount.toString()),
              ),
              trailing: FilledButton(
                onPressed: () =>
                    ref.read(cacheSizeProvider.notifier).clearAppImageCache(),
                child: const Text('settings.performance.clear_cache').tr(),
              ),
            );
          },
        ),
        Builder(
          builder: (context) {
            final sizeInfo = ref.watch(cacheSizeProvider);
            final size = sizeInfo.appCacheSize;

            return ListTile(
              title: const Text('All cache'),
              subtitle: Text(Filesize.parse(size.size)),
              trailing: FilledButton(
                onPressed: () =>
                    ref.read(cacheSizeProvider.notifier).clearAppCache(),
                child: const Text('settings.performance.clear_cache').tr(),
              ),
            );
          },
        ),
        SwitchListTile(
          value: settings.clearImageCacheOnStartup,
          title: const Text('settings.data_and_storage.clear_cache_on_start_up')
              .tr(),
          onChanged: (value) => notifier.updateSettings(
            settings.copyWith(clearImageCacheOnStartup: value),
          ),
        ),
        const Divider(),
        const SettingsHeader(label: 'Data'),
        Builder(
          builder: (context) {
            final cacheInfo = ref.watch(bookmarkCacheInfoProvider);

            return ListTile(
              title: const Text('Bookmark images'),
              subtitle: cacheInfo.when(
                data: (data) => Text(
                  Filesize.parse(data.$1),
                ),
                loading: () => const Text('Loading...'),
                error: (_, __) => const Text('Error loading cache info'),
              ),
              trailing: FilledButton(
                onPressed: () {
                  ref.read(bookmarkImageCacheManagerProvider).clearAllCache();
                  ref.invalidate(bookmarkCacheInfoProvider);
                },
                child: const Text('settings.performance.clear_cache').tr(),
              ),
            );
          },
        ),
      ],
    );
  }
}
