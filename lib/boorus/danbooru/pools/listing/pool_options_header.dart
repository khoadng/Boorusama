// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/widgets/widgets.dart';
import '../_internal/providers.dart';
import '../pool/danbooru_pool.dart';
import 'pool_order_l10n.dart';

class PoolOptionsHeader extends ConsumerWidget {
  const PoolOptionsHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(danbooruSelectedPoolOrderProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: ChoiceOptionSelectorList(
        icon: const Icon(Symbols.sort),
        options: DanbooruPoolOrder.values,
        hasNullOption: false,
        optionLabelBuilder: (value) =>
            value != null ? poolOrderToString(value).tr() : 'All',
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
