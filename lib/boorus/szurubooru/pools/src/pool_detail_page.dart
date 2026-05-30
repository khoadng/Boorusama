// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../core/bulk_downloads/routes.dart';
import '../../../../core/configs/config/providers.dart';
import '../../../../core/errors/types.dart';
import '../../../../core/posts/listing/widgets.dart';
import '../../../../core/posts/pools/widgets.dart';
import '../../../../core/search/search/routes.dart';
import '../../../../core/settings/providers.dart';
import '../../posts/providers.dart';
import '../../posts/types.dart';
import '../providers.dart';
import '../types.dart';

class SzurubooruPoolDetailPage extends ConsumerWidget {
  const SzurubooruPoolDetailPage({
    required this.poolId,
    this.initialPool,
    super.key,
  });

  final int poolId;
  final SzurubooruPool? initialPool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final details = ref.watch(szurubooruPoolProvider((config, poolId)));
    final effectivePool = details.valueOrNull ?? initialPool;

    if (effectivePool == null) {
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(context.t.pool.pool),
            floating: true,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: details.when(
                data: (_) => const Text('Pool not found'),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
        ],
      );
    }

    return _SzurubooruPoolPostList(
      pool: effectivePool,
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
                  tag: _poolSearchQuery(effectivePool),
                );
              },
            ),
            IconButton(
              onPressed: () {
                goToBulkDownloadPage(
                  context,
                  [_poolSearchQuery(effectivePool)],
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
              effectivePool.name?.replaceAll('_', ' ') ?? '???',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: _SzurubooruPoolMetadata(pool: effectivePool),
          ),
        ),
        if (details.isLoading)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(),
          ),
        if (effectivePool.description case final description?
            when description.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: MarkdownBody(data: description),
            ),
          ),
        SliverToBoxAdapter(
          child: _SzurubooruPoolOrderToggle(poolId: effectivePool.id),
        ),
      ],
    );
  }
}

class _SzurubooruPoolMetadata extends StatelessWidget {
  const _SzurubooruPoolMetadata({
    required this.pool,
  });

  final SzurubooruPool pool;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final summary = [
      if (pool.category case final category? when category.isNotEmpty)
        category.replaceAll('_', ' '),
      if (pool.postCount case final count?) context.t.posts.counter(n: count),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.isNotEmpty) Text(summary.join(' - ')),
        if (pool.updatedAt case final updatedAt?)
          Text(
            '${context.t.pool.detail.last_updated}: ${updatedAt.fuzzify(locale: locale)}',
          ),
      ],
    );
  }
}

class _SzurubooruPoolOrderToggle extends ConsumerWidget {
  const _SzurubooruPoolOrderToggle({
    required this.poolId,
  });

  final int poolId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PoolOrderToggle(
      value: ref.watch(szurubooruPoolDetailsOrderProvider(poolId)),
      onChanged: (value) {
        ref.read(szurubooruPoolDetailsOrderProvider(poolId).notifier).state =
            value;
      },
    );
  }
}

class _SzurubooruPoolPostList extends ConsumerWidget {
  const _SzurubooruPoolPostList({
    required this.pool,
    this.sliverHeaders,
  });

  final SzurubooruPool pool;
  final List<Widget>? sliverHeaders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perPage = ref.watch(
      imageListingSettingsProvider.select((value) => value.postsPerPage),
    );
    final config = ref.watchConfigSearch;
    final repo = ref.watch(szurubooruPostRepoProvider(config));
    final order = ref.watch(szurubooruPoolDetailsOrderProvider(pool.id));

    return PostScope<SzurubooruPost>(
      key: ValueKey((pool.postIds, order)),
      fetcher: (page) => TaskEither.tryCatch(
        () => repo.fetchPostIds(
          ids: pool.postIds,
          page: page,
          perPage: perPage,
          order: order,
        ),
        (error, stackTrace) => UnknownError(
          error: error,
          message: error.toString(),
        ),
      ),
      builder: (context, controller) => PostGrid<SzurubooruPost>(
        controller: controller,
        itemBuilder: (context, index, scrollController, useHero) =>
            DefaultImageGridItem<SzurubooruPost>(
              index: index,
              autoScrollController: scrollController,
              controller: controller,
              useHero: useHero,
              config: ref.watchConfigAuth,
            ),
        sliverHeaders: [
          ...?sliverHeaders,
        ],
      ),
    );
  }
}

String _poolSearchQuery(SzurubooruPool pool) => 'pool:${pool.id}';
