// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../pool/providers.dart';
import '../../pool/types.dart';
import '../../pool/widgets.dart';
import '../../search/routes.dart';
import 'pool_options_header.dart';

class DanbooruPoolPage extends ConsumerWidget {
  const DanbooruPoolPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(danbooruPoolFilterProvider);
    final filterNotifier = ref.watch(danbooruPoolFilterProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  titleSpacing: 0,
                  backgroundColor: colorScheme.surface,
                  title: Text(context.t.pool.pool_gallery),
                  actions: [
                    IconButton(
                      splashRadius: 24,
                      onPressed: () {
                        goToPoolSearchPage(ref);
                      },
                      icon: const Icon(Symbols.search),
                    ),
                  ],
                ),
                SliverPinnedHeader(
                  child: ColoredBox(
                    color: colorScheme.surface,
                    child: DefaultTabController(
                      initialIndex: filterState.category.toInt(),
                      length: 2,
                      child: TabBar(
                        isScrollable: true,
                        onTap: (value) {
                          filterNotifier.setCategory(
                            DanbooruPoolCategory.parse(value),
                          );
                        },
                        tabs: [
                          for (final e in DanbooruPoolCategory.allValues)
                            Tab(
                              text: e.localize(context),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: PoolOptionsHeader(),
                ),
                PoolPagedSliverGrid(
                  order: filterState.order,
                  category: filterState.category,
                  constraints: constraints,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
