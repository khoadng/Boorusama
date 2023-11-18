// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/option_dropdown_button.dart';

class PoolOptionsHeader extends ConsumerWidget {
  const PoolOptionsHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(danbooruSelectedPoolCategoryProvider);
    final order = ref.watch(danbooruSelectedPoolOrderProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentedButton(
            segments: PoolCategory.values
                .where((e) => e != PoolCategory.unknown)
                .map((e) => ButtonSegment(
                      value: e,
                      label: Text(_poolCategoryToString(e)).tr(),
                    ))
                .toList(),
            selected: {category},
            onSelectionChanged: (value) {
              ref.read(danbooruSelectedPoolCategoryProvider.notifier).state =
                  value.first;
            },
          ),
          OptionDropDownButton(
            value: order,
            alignment: AlignmentDirectional.centerStart,
            onChanged: (value) {
              if (value == null) return;
              ref.read(danbooruSelectedPoolOrderProvider.notifier).state =
                  value;
            },
            items: PoolOrder.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(_poolOrderToString(e)).tr(),
                    ))
                .toList(),
          ),
        ],
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
