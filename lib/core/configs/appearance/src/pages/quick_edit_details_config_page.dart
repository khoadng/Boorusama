// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../posts/details_manager/widgets.dart';
import '../../../config/data.dart';
import '../../../config/providers.dart';
import '../../../config/types.dart';
import '../../../manage/providers.dart';

class QuickEditDetailsConfigPage extends ConsumerWidget {
  const QuickEditDetailsConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watchLayoutConfigs ?? const LayoutConfigs.undefined();
    final uiBuilder = ref
        .watch(booruBuilderProvider(ref.watchConfigAuth))
        ?.postDetailsUIBuilder;

    if (uiBuilder == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Details'.hc),
        ),
        body: Center(
          child: Text('No builder found'.hc),
        ),
      );
    }

    final notifier = ref.watch(booruConfigProvider.notifier);
    final currentConfigNotifier = ref.watch(
      currentBooruConfigProvider.notifier,
    );
    final config = ref.watchConfig;

    return DetailsConfigPage(
      layout: layout,
      uiBuilder: uiBuilder,
      onLayoutUpdated: (layout) {
        notifier.update(
          booruConfigData: config
              .copyWith(
                layout: () => layout,
              )
              .toBooruConfigData(),
          oldConfigId: config.id,
          onSuccess: (booruConfig) {
            currentConfigNotifier.update(booruConfig);
          },
        );
      },
    );
  }
}
