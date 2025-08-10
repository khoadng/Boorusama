// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import 'selection_app_bar_builder.dart';

class DefaultSelectionBar extends StatelessWidget {
  const DefaultSelectionBar({
    required this.appBar,
    this.itemsCount,
    this.automaticallyImplyTrailing,
    super.key,
  });

  final Widget appBar;
  final int? itemsCount;
  final bool? automaticallyImplyTrailing;

  @override
  Widget build(BuildContext context) {
    return SelectionConsumer(
      builder: (context, controller, _) {
        final isSelectionMode = controller.isActive;

        return !isSelectionMode
            ? appBar
            : _SelectionAppBar(
                controller: controller,
                itemsCount: itemsCount,
              );
      },
    );
  }
}

class DefaultSelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DefaultSelectionAppBar({
    required this.itemsCount,
    this.appBar,
    super.key,
  });

  final int? itemsCount;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return SelectionAppBarBuilder(
      builder: (context, controller, isSelectionMode) => !isSelectionMode
          ? appBar ??
                AppBar(
                  title: Text(
                    context.t.settings.backup_and_restore.advanced_backup,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => controller.enable(),
                      child: Text(context.t.generic.action.select),
                    ),
                  ],
                )
          : _SelectionAppBar(
              itemsCount: itemsCount,
              controller: controller,
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SelectionAppBar({
    required this.itemsCount,
    required this.controller,
  });

  final int? itemsCount;
  final SelectionModeController controller;

  @override
  Widget build(BuildContext context) {
    final count = itemsCount;
    final selectAll = count != null
        ? controller.selection.length >= count
        : false;

    return AppBar(
      title: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final selectedCount = controller.selection.length;
          return Text(
            selectedCount <= 0
                ? context.t.select.selected_items
                : context.t.select.items_selected(n: selectedCount),
          );
        },
      ),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => controller.disable(),
      ),
      actions: [
        if (count != null && count > 0)
          selectAll
              ? IconButton(
                  onPressed: () {
                    controller.deselectAll();
                  },
                  icon: Icon(
                    Symbols.select_all,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    controller.selectAll(
                      List.generate(count, (index) => index),
                    );
                  },
                  icon: const Icon(Symbols.select_all),
                ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
