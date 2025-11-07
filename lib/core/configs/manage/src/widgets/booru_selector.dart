// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import '../../../../router.dart';
import '../../../../settings/providers.dart';
import '../../../config/providers.dart';
import '../../../config/types.dart';
import '../../../create/routes.dart';
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

    return Container(
      width: 68,
      color: Theme.of(context).colorScheme.surface,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ref
            .watch(orderedConfigsProvider)
            .maybeWhen(
              data: (configs) => CustomScrollView(
                reverse: reverseScroll,
                slivers: [
                  ReorderableSliverList(
                    onReorderStarted: (index) => showMenuIndex.value = index,
                    onDragStart: onDragStarted,
                    onDragUpdate: _onDragUpdate,
                    onDragEnd: onDragEnded,
                    delegate: ReorderableSliverChildBuilderDelegate(
                      (context, index) {
                        final config = configs[index];

                        return BooruSelectorItem(
                          hideLabel: hideLabel,
                          config: config,
                          showMenuIndex: showMenuIndex,
                          index: index,
                          onTap: () => ref.router.go('/?cid=${config.id}'),
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

    return Container(
      height: 48,
      color: Theme.of(context).colorScheme.surface,
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
                    onReorderStarted: (index) => showMenuIndex.value = index,
                    onDragStart: onDragStarted,
                    onDragUpdate: _onDragUpdate,
                    onDragEnd: onDragEnded,
                    delegate: ReorderableSliverChildBuilderDelegate(
                      (context, index) {
                        final config = configs[index];

                        return BooruSelectorItem(
                          hideLabel: hideLabel,
                          config: config,
                          index: index,
                          showMenuIndex: showMenuIndex,
                          onTap: () => ref.router.go('/?cid=${config.id}'),
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
    );
  }
}

mixin BooruSelectorActionMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  late final DragStateController _dragController;
  Offset? _startDragOffset;
  final showMenuIndex = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    _dragController = DragStateController();
  }

  @override
  void dispose() {
    _dragController.dispose();
    showMenuIndex.dispose();

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
        showMenuIndex.value = null;
      }
    }
  }

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
