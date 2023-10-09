// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

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
            Builder(
              builder: (context) {
                final size = ref.watch(cacheSizeProvider);

                return ListTile(
                  title: const Text('settings.performance.cache_size').tr(),
                  subtitle: Text('settings.performance.cache_size_info'
                      .tr()
                      .replaceAll('{0}', filesize(size.size))
                      .replaceAll('{1}', size.fileCount.toString())),
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
