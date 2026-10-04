// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import '../../../../router.dart';
import '../../../../settings/providers.dart';
import '../../../config/providers.dart';
import '../../../config/types.dart';
import '../../../create/routes.dart';
import '../pages/remove_booru_alert_dialog.dart';
import '../providers/booru_config_provider.dart';
import 'booru_selector_item.dart';
import 'drag_state_controller.dart';

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
  Axis get dragAxis => Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final currentConfig = ref.watchConfig;
    final notifier = ref.watch(booruConfigProvider.notifier);

    return railMenu(
      notifier,
      Container(
        width: 68,
        color: Kurumi.themeOf(context).colorScheme.surface,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ref
              .watch(orderedConfigsProvider)
              .maybeWhen(
                data: (configs) => CustomScrollView(
                  reverse: reverseScroll,
                  slivers: [
                    ReorderableSliverList(
                      onReorderStarted: (index) => show(configs[index]),
                      onDragStart: onDragStarted,
                      onDragUpdate: _onDragUpdate,
                      onDragEnd: onDragEnded,
                      delegate: ReorderableSliverChildBuilderDelegate(
                        (context, index) {
                          final config = configs[index];

                          return BooruSelectorItem(
                            hideLabel: hideLabel,
                            config: config,
                            onTap: () => ref.router.go('/?cid=${config.id}'),
                            onContextMenu: (position, {fromKeyboard = false}) =>
                                showAt(
                                  config,
                                  position,
                                  fromKeyboard: fromKeyboard,
                                ),
                            selected: currentConfig == config,
                            dragController: dragController,
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
  Axis get dragAxis => Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    final currentConfig = ref.watchConfig;
    final notifier = ref.watch(booruConfigProvider.notifier);

    return railMenu(
      notifier,
      Container(
        height: 48,
        color: Kurumi.themeOf(context).colorScheme.surface,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ref
              .watch(orderedConfigsProvider)
              .maybeWhen(
                data: (configs) => CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: reverseScroll,
                  slivers: [
                    ReorderableSliverList(
                      axis: Axis.horizontal,
                      onReorderStarted: (index) => show(configs[index]),
                      onDragStart: onDragStarted,
                      onDragUpdate: _onDragUpdate,
                      onDragEnd: onDragEnded,
                      delegate: ReorderableSliverChildBuilderDelegate(
                        (context, index) {
                          final config = configs[index];

                          return BooruSelectorItem(
                            hideLabel: hideLabel,
                            config: config,
                            onTap: () => ref.router.go('/?cid=${config.id}'),
                            onContextMenu: (position, {fromKeyboard = false}) =>
                                showAt(
                                  config,
                                  position,
                                  fromKeyboard: fromKeyboard,
                                ),
                            selected: currentConfig == config,
                            direction: Axis.horizontal,
                            dragController: dragController,
                          );
                        },
                        childCount: configs.length,
                      ),
                      onReorder: (oldIndex, newIndex) =>
                          onReorder(oldIndex, newIndex, configs),
                    ),
                    SliverToBoxAdapter(
                      child: addButton,
                    ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
        ),
      ),
    );
  }
}

mixin BooruSelectorActionMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  late final DragStateController _dragController;
  final _menu = KurumiContextMenuController();
  BooruConfig? _menuTarget;
  Offset? _lastPointer;
  Offset? _startDragOffset;

  @override
  void initState() {
    super.initState();
    _dragController = DragStateController();
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  Axis get dragAxis;

  DragStateController get dragController => _dragController;

  void onDragStarted() {
    _dragController.startDrag();
  }

  void onDragEnded() {
    _startDragOffset = null;
    _dragController.endDrag();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _startDragOffset ??= details.globalPosition;

    if (_startDragOffset != null) {
      final dragDistance = dragAxis == Axis.vertical
          ? details.globalPosition.dy - _startDragOffset!.dy
          : details.globalPosition.dx - _startDragOffset!.dx;
      if (dragDistance.abs() > 16) {
        hide();
      }
    }
  }

  // Long-press starts a reorder, which also opens the menu, and a dragged
  // item cannot host it, so one menu serves the whole rail.
  Widget railMenu(BooruConfigNotifier notifier, Widget rail) => Listener(
    onPointerDown: (event) => _lastPointer = event.position,
    child: KurumiContextMenu(
      controller: _menu,
      triggers: false,
      menuItemsBuilder: (_) => switch (_menuTarget) {
        final config? => menuItems(config, notifier),
        null => const [],
      },
      child: rail,
    ),
  );

  void showAt(
    BooruConfig config,
    Offset position, {
    bool fromKeyboard = false,
  }) {
    setState(() => _menuTarget = config);
    _menu.showAt(position, fromKeyboard: fromKeyboard);
  }

  void show(BooruConfig config) => switch (_lastPointer) {
    final position? => showAt(config, position),
    null => null,
  };

  void hide() => _menu.hide();

  List<Widget> menuItems(BooruConfig config, BooruConfigNotifier notifier) => [
    KurumiContextMenuTile(
      title: context.t.generic.action.edit,
      onTap: () => goToUpdateBooruConfigPage(
        ref,
        config: config,
      ),
    ),
    KurumiContextMenuTile(
      title: context.t.generic.action.duplicate,
      onTap: () => notifier.duplicate(config: config),
    ),
    KurumiContextMenuTile(
      title: context.t.generic.action.delete,
      destructive: true,
      onTap: () {
        showDialog(
          context: context,
          routeSettings: const RouteSettings(name: 'booru/delete'),
          builder: (context) => RemoveBooruConfigAlertDialog(
            title: context.t.booru.deletion.title(
              profileName: config.name,
            ),
            description: context.t.booru.deletion.confirmation,
            onConfirm: () => notifier.delete(
              config,
              onFailure: (message) => Kurumi.showErrorToast(context, message),
            ),
          ),
        );
      },
    ),
  ];

  void onReorder(int oldIndex, int newIndex, Iterable<BooruConfig> configs) {
    ref.read(booruConfigProvider.notifier).reorder(oldIndex, newIndex, configs);
  }

  bool get reverseScroll => ref.watch(
    settingsProvider.select(
      (value) => value.booruConfigSelectorScrollDirection.isReversed,
    ),
  );

  bool get hideLabel => ref.watch(
    settingsProvider.select(
      (value) => value.booruConfigLabelVisibility.hideBooruConfigLabel,
    ),
  );

  Widget get addButton => IconButton(
    splashRadius: 20,
    onPressed: () => goToAddBooruConfigPage(ref),
    icon: const Icon(Symbols.add),
  );
}
