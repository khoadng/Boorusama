// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../providers.dart';
import 'pool_grid.dart';
import 'pool_options_header.dart';
import 'routes/route_utils.dart';

class SzurubooruPoolPage extends ConsumerWidget {
  const SzurubooruPoolPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(szurubooruPoolFilterProvider);

    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(context.t.pool.pool_gallery),
                  floating: true,
                  snap: true,
                  actions: [
                    IconButton(
                      onPressed: () => goToSzurubooruPoolSearchPage(ref),
                      icon: const Icon(Symbols.search),
                    ),
                  ],
                ),
                const SliverToBoxAdapter(
                  child: SzurubooruPoolOptionsHeader(),
                ),
                SzurubooruPoolPagedSliverGrid(
                  constraints: constraints,
                  order: order,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
