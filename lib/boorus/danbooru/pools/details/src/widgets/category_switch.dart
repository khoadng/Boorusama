// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../posts/post/types.dart';
import '../providers/filter_provider.dart';
import '../types/pool_details_order.dart';

class PoolCategoryToggleSwitch extends ConsumerWidget {
  const PoolCategoryToggleSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = PostScope.of<DanbooruPost>(context);
    final notifier = ref.watch(poolFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Center(
        child: BooruSegmentedButton(
          initialValue: ref.watch(
            poolFilterProvider.select((state) => state.order),
          ),
          fixedWidth: 120,
          segments: {
            for (final order in PoolDetailsOrder.values)
              order: order.localize(context),
          },
          onChanged: (value) {
            notifier.setOrder(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.refresh();
            });
          },
        ),
      ),
    );
  }
}
