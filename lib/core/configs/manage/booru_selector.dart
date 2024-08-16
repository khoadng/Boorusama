// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'booru_selector_item.dart';
import 'remove_booru_alert_dialog.dart';

class BooruSelector extends ConsumerWidget {
  const BooruSelector({
    super.key,
    this.direction = Axis.vertical,
  });

  final Axis direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return direction == Axis.vertical
        ? const BooruSelectorVertical()
        : const BooruSelectorHorizontal();
  }
}

class BooruSelectorVertical extends ConsumerStatefulWidget {
  const BooruSelectorVertical({
    super.key,
  });

  @override
  ConsumerState<BooruSelectorVertical> createState() =>
      _BooruSelectorVerticalState();
}

class _BooruSelectorVerticalState extends ConsumerState<BooruSelectorVertical>
    with BooruSelectorActionMixin {
  @override
  Widget build(BuildContext context) {
    final currentConfig = ref.watchConfig;

    return Container(
      width: 68,
      color: context.colorScheme.secondaryContainer,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ref.watch(configsProvider).maybeWhen(
              data: (configs) => CustomScrollView(
                reverse: reverseScroll,
                scrollDirection: Axis.vertical,
                slivers: [
                  ReorderableSliverList(
                    onReorderStarted: (index) => show(configs[index]),
                    onHover: (start, current) => hide(),
                    delegate: ReorderableSliverChildBuilderDelegate(
                      (context, index) {
                        final config = configs[index];

                        return BooruSelectorItem(
                          hideLabel: hideLabel,
                          config: config,
                          show: () => show(config),
                          onTap: () => ref
                              .read(currentBooruConfigProvider.notifier)
                              .update(config),
                          selected: currentConfig == config,
                          direction: Axis.vertical,
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
                  SliverSizedBox(
                    height: MediaQuery.viewPaddingOf(context).bottom + 12,
                  ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
      ),
    );
  }
}

class BooruSelectorHorizontal extends ConsumerStatefulWidget {
  const BooruSelectorHorizontal({
    super.key,
  });

  @override
  ConsumerState<BooruSelectorHorizontal> createState() =>
      _BooruSelectorHorizontalState();
}

class _BooruSelectorHorizontalState
    extends ConsumerState<BooruSelectorHorizontal>
    with BooruSelectorActionMixin {
  @override
  Widget build(BuildContext context) {
    final currentConfig = ref.watchConfig;

    return Container(
      height: 48,
      color: context.colorScheme.secondaryContainer,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ref.watch(configsProvider).maybeWhen(
              data: (configs) => Row(
                children: [
                  if (reverseScroll) addButton,
                  Expanded(
                    child: ReorderableRow(
                      onReorderStarted: (index) => show(configs[index]),
                      onReorder: (oldIndex, newIndex) =>
                          onReorder(oldIndex, newIndex, configs),
                      children: [
                        for (final config in () {
                          return reverseScroll ? configs.reversed : configs;
                        }())
                          Container(
                            key: ValueKey(config.id),
                            child: BooruSelectorItem(
                              hideLabel: hideLabel,
                              config: config,
                              show: () => show(config),
                              onTap: () => ref
                                  .read(currentBooruConfigProvider.notifier)
                                  .update(config),
                              selected: currentConfig == config,
                              direction: Axis.horizontal,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!reverseScroll) addButton,
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
      ),
    );
  }
}

mixin BooruSelectorActionMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
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
              if (kPreferredLayout.isMobile) {
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
                      onConfirm: () =>
                          ref.read(booruConfigProvider.notifier).delete(
                                config,
                                onFailure: (message) =>
                                    showErrorToast(context, message),
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
                              onFailure: (message) =>
                                  showErrorToast(context, message),
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
    final orders = ref.read(settingsProvider).booruConfigIdOrderList;
    final newOrders = orders.isEmpty || orders.length != configs.length
        ? [for (final config in configs) config.id]
        : orders.toList();

    newOrders.reorder(oldIndex, newIndex);

    ref.read(settingsProvider.notifier).updateOrder(newOrders);
  }

  bool get reverseScroll => ref.watch(settingsProvider
      .select((value) => value.reverseBooruConfigSelectorScrollDirection));

  bool get hideLabel =>
      ref.watch(settingsProvider.select((value) => value.hideBooruConfigLabel));

  Widget get addButton => IconButton(
        splashRadius: 20,
        onPressed: () => context.go('/boorus/add'),
        icon: const Icon(Symbols.add),
      );
}
