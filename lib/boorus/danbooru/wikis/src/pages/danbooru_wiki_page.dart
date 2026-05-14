// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../../../core/widgets/widgets.dart';
import '../types/wiki.dart';
import '../widgets/danbooru_wiki_dtext_body.dart';
import '../wiki_providers.dart';

class DanbooruWikiPage extends ConsumerWidget {
  const DanbooruWikiPage({
    required this.wikiPageName,
    super.key,
  });

  final String wikiPageName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wiki = ref.watch(danbooruWikiProvider(wikiPageName));
    final wikiValue = wiki.valueOrNull;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (wikiValue?.type case TagWiki(:final tag))
            IconButton(
              onPressed: () => goToSearchPage(ref, tag: tag),
              icon: const Icon(Symbols.search),
            ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () =>
            ref.read(danbooruWikiProvider(wikiPageName).notifier).reload(),
        child: wiki.when(
          data: (wiki) {
            if (wiki == null) {
              return const _WikiPageFill(
                child: NoDataBox(),
              );
            }

            return CustomScrollView(
              cacheExtent: 0,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverList.list(
                    children: [
                      Text(
                        wiki.title.replaceAll('_', ' '),
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (wiki.otherNames.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final name in wiki.otherNames)
                              RawTagChip(
                                text: name.replaceAll('_', ' '),
                                maxTextLength: 100,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                backgroundColor: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                foregroundColor: colorScheme.primary,
                                borderColor: colorScheme.primary.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: DanbooruWikiDTextSliverBody(data: wiki.body),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 24),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox.shrink(),
                  ),
                ),
              ],
            );
          },
          loading: () => const _WikiPageFill(
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (error, _) => _WikiPageFill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(error.toString()),
            ),
          ),
        ),
      ),
    );
  }
}

class _WikiPageFill extends StatelessWidget {
  const _WikiPageFill({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.65,
          child: Center(child: child),
        ),
      ],
    );
  }
}
