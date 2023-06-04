// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/boorus/booru_config_info_tile.dart';
import 'package:boorusama/router.dart';

class SwitchBooruModal extends ConsumerWidget {
  const SwitchBooruModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConfig = ref.watch(currentBooruConfigProvider);
    final configs = ref
        .watch(booruConfigProvider)
        .where((c) => c.id != currentConfig.id)
        .toList();
    final booruFactory = ref.watch(booruFactoryProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            BooruConfigInfoTile(
              booru: currentConfig.createBooruFrom(booruFactory),
              config: currentConfig,
              isCurrent: true,
            ),
            const Divider(),
            ListTile(
              horizontalTitleGap: 8,
              visualDensity: VisualDensity.compact,
              title: const Text('Add new booru'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/boorus/add?setAsCurrent=true');
              },
              leading: const Icon(Icons.add),
            ),
            Expanded(
              child: ListView.builder(
                controller: ModalScrollController.of(context),
                itemCount: configs.length,
                itemBuilder: (context, index) {
                  final config = configs[index];
                  final booru = config.createBooruFrom(booruFactory);

                  return BooruConfigInfoTile(
                    booru: booru,
                    config: config,
                    isCurrent: false,
                    onTap: () {
                      ref
                          .read(currentBooruConfigProvider.notifier)
                          .update(config);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
