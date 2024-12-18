// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../_shared/providers/providers.dart';
import '../../../_shared/widgets/pool_page_sliver_grid.dart';
import '../providers.dart';

class PoolSearchResultView extends ConsumerWidget {
  const PoolSearchResultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
          slivers: [
            PoolPagedSliverGrid(
              order: ref.watch(danbooruSelectedPoolOrderProvider),
              category: ref.watch(danbooruSelectedPoolCategoryProvider),
              constraints: constraints,
              name: ref.watch(danbooruPoolQueryProvider),
            ),
          ],
        ),
      ),
    );
  }
}
