// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/pools/widgets.dart';
import '../providers/filter_provider.dart';

class PoolCategoryToggleSwitch extends ConsumerWidget {
  const PoolCategoryToggleSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(poolFilterProvider.notifier);

    return PoolOrderToggle(
      value: ref.watch(poolFilterProvider.select((state) => state.order)),
      onChanged: notifier.setOrder,
    );
  }
}
