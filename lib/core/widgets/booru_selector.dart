// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';

class BooruSelector extends ConsumerStatefulWidget {
  const BooruSelector({
    super.key,
  });

  @override
  ConsumerState<BooruSelector> createState() => _BooruSelectorState();
}

class _BooruSelectorState extends ConsumerState<BooruSelector> {
  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(configsProvider);
    final currentConfig = ref.watchConfig;

    void show(BooruConfig config) {
      context.contextMenuOverlay.show(
        GenericContextMenu(
          buttonConfigs: [
            ContextMenuButtonConfig(
              'generic.action.edit'.tr(),
              onPressed: () => context.go('/boorus/${config.id}/update'),
            ),
            ContextMenuButtonConfig(
              'Duplicate',
              onPressed: () => ref
                  .read(booruConfigProvider.notifier)
                  .duplicate(config: config),
            ),
            if (currentConfig != config)
              ContextMenuButtonConfig(
                'generic.action.delete'.tr(),
                labelStyle: TextStyle(
                  color: context.colorScheme.error,
                ),
                onPressed: () {
                  if (isMobilePlatform()) {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: RemoveBooruConfigAlertDialog(
                          title: "Delete '${config.name}'",
                          description:
                              'Are you sure you want to delete this profile? This action cannot be undone.',
                          onConfirm: () => ref
                              .read(booruConfigProvider.notifier)
                              .delete(config),
                        ),
                      ),
                    );
                  } else {
                    showDesktopDialogWindow(
                      context,
                      width: 400,
                      height: 300,
                      builder: (context) => RemoveBooruConfigAlertDialog(
                        title: "Delete '${config.name}'",
                        description:
                            'Are you sure you want to delete this profile? This action cannot be undone.',
                        onConfirm: () => ref
                            .read(booruConfigProvider.notifier)
                            .delete(config),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      );
    }

    void hide() => context.contextMenuOverlay.hide();

    return Container(
      width: 68,
      color: context.colorScheme.secondaryContainer,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          slivers: [
            ReorderableSliverList(
                onReorderStarted: (index) => show(configs[index]),
                onHover: (start, current) => hide(),
                delegate: ReorderableSliverChildBuilderDelegate(
                  (context, index) {
                    final config = configs[index];

                    return BooruSelectorItem(
                      config: config,
                      show: () => show(config),
                      onTap: () => ref
                          .read(currentBooruConfigProvider.notifier)
                          .update(config),
                      selected: currentConfig == config,
                    );
                  },
                  childCount: configs.length,
                ),
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex == newIndex) return;

                  final orders = ref.read(configIdOrdersProvider);
                  final newOrders =
                      (orders.isEmpty || orders.length != configs.length
                              ? [for (final config in configs) config.id]
                              : orders)
                          .toList();

                  newOrders.reorder(oldIndex, newIndex);

                  ref.setBooruConfigOrder(newOrders);
                }),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    IconButton(
                      splashRadius: 20,
                      onPressed: () => context.go('/boorus/add'),
                      icon: const Icon(Symbols.add),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BooruSelectorItem extends StatelessWidget {
  const BooruSelectorItem({
    super.key,
    required this.config,
    required this.onTap,
    required this.show,
    required this.selected,
  });

  final BooruConfig config;
  final bool selected;
  final void Function() show;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey(config.id),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        hoverColor: context.theme.hoverColor.withOpacity(0.1),
        onSecondaryTap: () => show(),
        onTap: onTap,
        child: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color:
                    selected ? context.colorScheme.primary : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              switch (PostSource.from(config.url)) {
                WebSource source => BooruLogo(source: source),
                _ => const Card(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                    ),
                  ),
              },
              const SizedBox(height: 4),
              Text(
                config.name,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RemoveBooruConfigAlertDialog extends StatelessWidget {
  const RemoveBooruConfigAlertDialog({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.description,
  });

  final void Function() onConfirm;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.errorContainer,
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: context.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
