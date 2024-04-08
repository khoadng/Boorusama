// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
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
import 'package:boorusama/widgets/widgets.dart';

class BooruSelector extends ConsumerStatefulWidget {
  const BooruSelector({
    super.key,
    this.direction = Axis.vertical,
  });

  final Axis direction;

  @override
  ConsumerState<BooruSelector> createState() => _BooruSelectorState();
}

class _BooruSelectorState extends ConsumerState<BooruSelector> {
  @override
  Widget build(BuildContext context) {
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
              'generic.action.duplicate'.tr(),
              onPressed: () => ref
                  .read(booruConfigProvider.notifier)
                  .duplicate(config: config),
            ),
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
                            .delete(
                              config,
                              onFailure: (message) => showErrorToast(message),
                            ),
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
                      onConfirm: () =>
                          ref.read(booruConfigProvider.notifier).delete(
                                config,
                                onFailure: (message) => showErrorToast(message),
                              ),
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

    void onReorder(int oldIndex, int newIndex, Iterable<BooruConfig> configs) {
      final orders = ref.read(configIdOrdersProvider);
      final newOrders = orders.isEmpty || orders.length != configs.length
          ? [for (final config in configs) config.id]
          : orders.toList();

      newOrders.reorder(oldIndex, newIndex);

      ref.setBooruConfigOrder(newOrders);
    }

    final addButton = IconButton(
      splashRadius: 20,
      onPressed: () => context.go('/boorus/add'),
      icon: const Icon(Symbols.add),
    );

    final reverseScroll = ref.watch(settingsProvider
        .select((value) => value.reverseBooruConfigSelectorScrollDirection));

    return Container(
      padding: widget.direction == Axis.horizontal
          ? const EdgeInsets.only(left: 8)
          : null,
      height: widget.direction == Axis.horizontal ? 48 : null,
      width: widget.direction == Axis.vertical ? 68 : null,
      color: context.colorScheme.secondaryContainer,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ref.watch(configsProvider).maybeWhen(
              data: (configs) {
                return widget.direction == Axis.vertical
                    ? CustomScrollView(
                        reverse: reverseScroll,
                        scrollDirection: widget.direction,
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
                                  direction: widget.direction,
                                );
                              },
                              childCount: configs.length,
                            ),
                            onReorder: (oldIndex, newIndex) =>
                                onReorder(oldIndex, newIndex, configs),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: [
                                  addButton,
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          if (reverseScroll)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: addButton,
                            ),
                          Expanded(
                            child: ReorderableRow(
                              onReorderStarted: (index) => show(configs[index]),
                              onReorder: (oldIndex, newIndex) =>
                                  onReorder(oldIndex, newIndex, configs),
                              children: [
                                for (final config in () {
                                  return reverseScroll
                                      ? configs.reversed
                                      : configs;
                                }())
                                  Container(
                                    key: ValueKey(config.id),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: BooruSelectorItem(
                                      config: config,
                                      show: () => show(config),
                                      onTap: () => ref
                                          .read(currentBooruConfigProvider
                                              .notifier)
                                          .update(config),
                                      selected: currentConfig == config,
                                      direction: widget.direction,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!reverseScroll)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: addButton,
                            ),
                        ],
                      );
              },
              orElse: () => const SizedBox.shrink(),
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
    this.direction = Axis.vertical,
  });

  final BooruConfig config;
  final bool selected;
  final void Function() show;
  final void Function() onTap;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final bds = BorderSide(
      color: selected ? context.colorScheme.primary : Colors.transparent,
      width: direction == Axis.vertical ? 3 : 4,
    );

    return Material(
      key: ValueKey(config.id),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        hoverColor: context.theme.hoverColor.withOpacity(0.1),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onSecondaryTap: () => show(),
        onTap: onTap,
        child: Container(
          width: direction == Axis.vertical ? 60 : 72,
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          margin: EdgeInsets.symmetric(
            vertical: direction == Axis.vertical ? 8 : 0,
          ),
          decoration: BoxDecoration(
            border: direction == Axis.vertical
                ? Border(
                    left: bds,
                  )
                : Border(
                    top: bds,
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: Text(
                  config.name,
                  textAlign: TextAlign.center,
                  maxLines: direction == Axis.vertical ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                  ),
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
                'generic.action.delete'.tr(),
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
                'generic.action.cancel'.tr(),
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
