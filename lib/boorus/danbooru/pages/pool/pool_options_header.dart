// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/pools/pools.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/i18n.dart';

class PoolOptionsHeader extends ConsumerWidget {
  const PoolOptionsHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) {
              final category = ref.watch(danbooruSelectedPoolCategoryProvider);

              return ToggleSwitch(
                initialLabelIndex: switch (category) {
                  PoolCategory.series => 0,
                  PoolCategory.collection => 1,
                  PoolCategory.unknown => 0,
                },
                changeOnTap: false,
                minHeight: 30,
                minWidth: 100,
                cornerRadius: 10,
                totalSwitches: 2,
                borderWidth: 1,
                inactiveBgColor: Theme.of(context).chipTheme.backgroundColor,
                activeBgColor: [Theme.of(context).colorScheme.primary],
                labels: [
                  _poolCategoryToString(PoolCategory.series).tr(),
                  _poolCategoryToString(PoolCategory.collection).tr(),
                ],
                onToggle: (index) {
                  ref
                          .read(danbooruSelectedPoolCategoryProvider.notifier)
                          .state =
                      index == 0
                          ? PoolCategory.series
                          : PoolCategory.collection;
                },
              );
            },
          ),
          Builder(
            builder: (context) {
              final order = ref.watch(danbooruSelectedPoolOrderProvider);

              return TextButton(
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).textTheme.titleLarge!.color,
                  backgroundColor: Theme.of(context).cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                onPressed: () {
                  Screen.of(context).size == ScreenSize.small
                      ? showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => const _OrderMenu(),
                        )
                      : showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            contentPadding: EdgeInsets.zero,
                            content: _OrderMenu(),
                          ),
                        );
                },
                child: Row(
                  children: [
                    Text(_poolOrderToString(order)).tr(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrderMenu extends ConsumerWidget {
  const _OrderMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PoolOrder.values
              .map((e) => ListTile(
                    title: Text(_poolOrderToString(e)).tr(),
                    onTap: () {
                      Navigator.of(context).pop();
                      ref
                          .read(danbooruSelectedPoolOrderProvider.notifier)
                          .state = e;
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

String _poolOrderToString(PoolOrder order) => switch (order) {
      PoolOrder.newest => 'pool.order.new',
      PoolOrder.postCount => 'pool.order.post_count',
      PoolOrder.name => 'pool.order.name',
      PoolOrder.latest => 'pool.order.recent'
    };

String _poolCategoryToString(PoolCategory category) =>
    'pool.category.${category.name}';
