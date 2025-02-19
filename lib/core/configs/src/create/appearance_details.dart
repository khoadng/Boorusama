// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../posts/details_manager/widgets.dart';
import '../booru_config.dart';
import '../booru_config_converter.dart';
import '../booru_config_ref.dart';
import '../manage/booru_config_provider.dart';
import '../manage/current_booru_providers.dart';

class QuickEditDetailsConfigPage extends ConsumerWidget {
  const QuickEditDetailsConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watchLayoutConfigs ?? const LayoutConfigs.undefined();
    final uiBuilder =
        ref.watchBooruBuilder(ref.watchConfigAuth)?.postDetailsUIBuilder;

    if (uiBuilder == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
        ),
        body: const Center(
          child: Text('No builder found'),
        ),
      );
    }

    final notifier = ref.watch(booruConfigProvider.notifier);
    final currentConfigNotifier =
        ref.watch(currentBooruConfigProvider.notifier);
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

void goToQuickEditPostDetailsLayoutPage(
  BuildContext context,
) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const QuickEditDetailsConfigPage(),
    ),
  );
}
