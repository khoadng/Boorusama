// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/bulk_downloads/routes.dart';
import '../../../../../core/search/search/routes.dart';
import '../../pool/types.dart';
import 'types/query_utils.dart';
import 'widgets/category_switch.dart';
import 'widgets/danbooru_infinite_post_id_list.dart';
import 'widgets/description_section.dart';

class PoolDetailPage extends ConsumerWidget {
  const PoolDetailPage({
    required this.pool,
    super.key,
  });

  final DanbooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DanbooruInfinitePostIdList(
      pool: pool,
      sliverHeaders: [
        SliverAppBar(
          title: Text(context.t.pool.pool),
          floating: true,
          actions: [
            IconButton(
              icon: const Icon(Symbols.search),
              onPressed: () {
                goToSearchPage(
                  ref,
                  tag: pool.toSearchQuery(),
                );
              },
            ),
            IconButton(
              onPressed: () {
                goToBulkDownloadPage(
                  context,
                  [
                    pool.toSearchQuery(),
                  ],
                  ref: ref,
                );
              },
              icon: const Icon(Symbols.download),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(
              pool.name?.replaceAll('_', ' ') ?? '???',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              '${context.t.pool.detail.last_updated}: ${pool.updatedAt?.fuzzify(locale: Localizations.localeOf(context))}',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: PoolDescriptionSection(
            pool: pool,
          ),
        ),
        const SliverToBoxAdapter(
          child: PoolCategoryToggleSwitch(),
        ),
      ],
    );
  }
}
