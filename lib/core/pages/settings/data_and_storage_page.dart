// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/settings_header.dart';

class DataAndStoragePage extends ConsumerStatefulWidget {
  const DataAndStoragePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<DataAndStoragePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends ConsumerState<DataAndStoragePage> {
  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('Data and Storage'),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
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
                  trailing: ElevatedButton(
                    onPressed: () => ref
                        .read(cacheSizeProvider.notifier)
                        .clearAppImageCache(),
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
                  subtitle: Text(filesize(size.size)),
                  trailing: ElevatedButton(
                    onPressed: () =>
                        ref.read(cacheSizeProvider.notifier).clearAppCache(),
                    child: const Text('settings.performance.clear_cache').tr(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
