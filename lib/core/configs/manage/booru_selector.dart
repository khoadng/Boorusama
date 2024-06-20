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
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
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
      final orders = ref.read(settingsProvider).booruConfigIdOrderList;
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

    final hideLabel = ref
        .watch(settingsProvider.select((value) => value.hideBooruConfigLabel));

    return Container(
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
                                  hideLabel: hideLabel,
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
                          SliverSizedBox(
                            height:
                                MediaQuery.viewPaddingOf(context).bottom + 12,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          if (reverseScroll) addButton,
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
                                      hideLabel: hideLabel,
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
                          if (!reverseScroll) addButton,
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
    this.hideLabel = false,
  });

  final BooruConfig config;
  final bool selected;
  final void Function() show;
  final void Function() onTap;
  final Axis direction;
  final bool hideLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey(config.id),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: ConditionalParentWidget(
        condition: hideLabel,
        conditionalBuilder: (child) => Tooltip(
          message: config.name,
          triggerMode: TooltipTriggerMode.manual,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
        child: _build(context),
      ),
    );
  }

  Widget _build(BuildContext context) {
    final logoSize = hideLabel
        ? kPreferredLayout.isMobile
            ? 40.0
            : 36.0
        : null;

    return Container(
      margin: direction == Axis.vertical
          ? EdgeInsets.symmetric(
              vertical: kPreferredLayout.isMobile ? 8 : 4,
            )
          : const EdgeInsets.only(
              bottom: 4,
              left: 4,
            ),
      child: InkWell(
        hoverColor: context.theme.hoverColor.withOpacity(0.1),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onSecondaryTap: () => show(),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (direction == Axis.horizontal)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: selected
                            ? context.colorScheme.primary
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: selected
                            ? context.colorScheme.primary
                            : Colors.transparent,
                        width: 48,
                      ),
                    ),
                  ),
                ),
              ),
            Container(
              width: direction == Axis.vertical
                  ? 60
                  : hideLabel
                      ? 52
                      : 72,
              decoration: BoxDecoration(
                border: direction == Axis.vertical
                    ? const Border(
                        left: BorderSide(
                          color: Colors.transparent,
                          width: 4,
                        ),
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (direction == Axis.horizontal)
                    const SizedBox(height: 12)
                  else
                    const SizedBox(height: 4),
                  Container(
                    padding: kPreferredLayout.isDesktop
                        ? EdgeInsets.symmetric(
                            vertical: hideLabel ? 4 : 0,
                          )
                        : null,
                    child: switch (PostSource.from(config.url)) {
                      WebSource source => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BooruLogo(
                            source: source,
                            width: logoSize,
                            height: logoSize,
                          ),
                        ),
                      _ => Card(
                          child: SizedBox(
                            width: logoSize,
                            height: logoSize,
                          ),
                        ),
                    },
                  ),
                  if (direction == Axis.horizontal && hideLabel)
                    const SizedBox(height: 8)
                  else
                    const SizedBox(height: 4),
                  if (!hideLabel)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        bottom: 4,
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
          ],
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
                  color: Theme.of(context).colorScheme.onSurface,
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
