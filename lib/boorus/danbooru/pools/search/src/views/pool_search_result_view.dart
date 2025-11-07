// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../pool/src/providers/pool_filter_provider.dart';
import '../../../pool/widgets.dart';
import '../providers.dart';

class PoolSearchResultView extends ConsumerWidget {
  const PoolSearchResultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(danbooruPoolFilterProvider);

    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
          slivers: [
            PoolPagedSliverGrid(
              order: filterState.order,
              category: filterState.category,
              constraints: constraints,
              name: ref.watch(danbooruPoolQueryProvider),
            ),
          ],
        ),
      ),
    );
  }
}
