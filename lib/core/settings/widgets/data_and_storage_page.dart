// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_page_scaffold.dart';

final tagHighlightingCacheProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final dirPath = ref.watch(booruTagTypePathProvider);

  if (dirPath == null) return 0;

  final path = await BooruTagTypeStore.getBoxPath(dirPath);
  final file = File(path);

  if (!file.existsSync()) return 0;

  return file.lengthSync();
});

class DataAndStoragePage extends ConsumerStatefulWidget {
  const DataAndStoragePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<DataAndStoragePage> createState() => _DataAndStoragePageState();
}

class _DataAndStoragePageState extends ConsumerState<DataAndStoragePage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return SettingsPageScaffold(
      hasAppBar: widget.hasAppBar,
      title: const Text('settings.data_and_storage.data_and_storage').tr(),
      children: [
        const SettingsHeader(label: 'Cache'),
        Builder(
          builder: (context) {
            final sizeInfo = ref.watch(cacheSizeProvider);
            final imageCacheSize = sizeInfo.imageCacheSize;

            return ListTile(
              title: const Text('Image only cache'),
              subtitle: Text('settings.performance.cache_size_info'
                  .tr()
                  .replaceAll('{0}', filesize(imageCacheSize.size))
                  .replaceAll('{1}', imageCacheSize.fileCount.toString())),
              trailing: FilledButton(
                onPressed: () =>
                    ref.read(cacheSizeProvider.notifier).clearAppImageCache(),
                child: const Text('settings.performance.clear_cache').tr(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Tag highlighting cache'),
          subtitle: ref.watch(tagHighlightingCacheProvider).maybeWhen(
                data: (data) => Text(filesize(data)),
                orElse: () => const Text('Loading...'),
              ),
          trailing: FilledButton(
            onPressed: () => ref
                .read(booruTagTypeStoreProvider)
                .clear()
                .then((value) => ref.invalidate(tagHighlightingCacheProvider)),
            child: const Text('settings.performance.clear_cache').tr(),
          ),
        ),
        Builder(
          builder: (context) {
            final sizeInfo = ref.watch(cacheSizeProvider);
            final size = sizeInfo.appCacheSize;

            return ListTile(
              title: const Text('All cache'),
              subtitle: Text(filesize(size.size)),
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
          onChanged: (value) => ref.updateSettings(
            settings.copyWith(clearImageCacheOnStartup: value),
          ),
        ),
      ],
    );
  }
}
