// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../pool/providers.dart';
import '../../pool/types.dart';

class PoolOptionsHeader extends ConsumerWidget {
  const PoolOptionsHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(
      danbooruPoolFilterProvider.select((value) => value.order),
    );
    final notifier = ref.watch(danbooruPoolFilterProvider.notifier);

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
            value != null ? value.localize(context) : 'All'.hc,
        sheetTitle: context.t.sort.sort_by,
        onSelected: (value) {
          notifier.setOrder(value ?? DanbooruPoolOrder.newest);
        },
        selectedOption: order,
      ),
    );
  }
}
