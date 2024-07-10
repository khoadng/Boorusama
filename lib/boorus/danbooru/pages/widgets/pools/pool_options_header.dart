// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class PoolOptionsHeader extends ConsumerWidget {
  const PoolOptionsHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(danbooruSelectedPoolOrderProvider);

    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: ChoiceOptionSelectorList(
        icon: const Icon(Symbols.sort),
        options: DanbooruPoolOrder.values,
        hasNullOption: false,
        optionLabelBuilder: (value) =>
            value != null ? _poolOrderToString(value).tr() : 'All',
        sheetTitle: 'Sort by',
        onSelected: (value) {
          ref.read(danbooruSelectedPoolOrderProvider.notifier).state =
              value ?? DanbooruPoolOrder.newest;
        },
        selectedOption: order,
      ),
    );
  }
}

String _poolOrderToString(DanbooruPoolOrder order) => switch (order) {
      DanbooruPoolOrder.newest => 'pool.order.new',
      DanbooruPoolOrder.postCount => 'pool.order.post_count',
      DanbooruPoolOrder.name => 'pool.order.name',
      DanbooruPoolOrder.latest => 'pool.order.recent',
    };
