// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/application/booru_config_notifier.dart';
import 'package:boorusama/core/application/current_booru_notifier.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/boorus/booru_config_info_tile.dart';

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
    final booruFactory = context.read<BooruFactory>();

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
                goToAddBooruPage(
                  context,
                  setCurrentBooruOnSubmit: true,
                );
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
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
