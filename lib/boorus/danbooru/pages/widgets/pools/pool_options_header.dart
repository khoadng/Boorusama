// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

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
          BooruSegmentedButton(
            segments: {
              for (final category in PoolCategory.values
                  .where((e) => e != PoolCategory.unknown))
                category: _poolCategoryToString(category).tr(),
            },
            initialValue: category,
            onChanged: (value) {
              ref.read(danbooruSelectedPoolCategoryProvider.notifier).state =
                  value;
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
