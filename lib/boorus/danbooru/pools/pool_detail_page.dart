// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/utils/html_utils.dart';
import 'package:boorusama/widgets/widgets.dart';

final selectedPoolDetailsOrderProvider = StateProvider.autoDispose<String>(
  (ref) => 'order',
);

final poolPostIdsProvider =
    Provider.autoDispose.family<List<int>, DanbooruPool>(
  (ref, pool) {
    final selectedOrder = ref.watch(selectedPoolDetailsOrderProvider);
    final postIds = [...pool.postIds];

    final sorted = switch (selectedOrder) {
      'latest' => postIds.sorted((a, b) => b.compareTo(a)),
      'oldest' => postIds.sorted((a, b) => a.compareTo(b)),
      _ => postIds,
    };

    return sorted;
  },
);

class PoolDetailPage extends ConsumerWidget {
  const PoolDetailPage({
    super.key,
    required this.pool,
  });

  final DanbooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolDesc = ref.watch(poolDescriptionProvider(pool.id));
    final config = ref.watchConfigAuth;

    return CustomContextMenuOverlay(
      child: DanbooruInfinitePostIdList(
        ids: ref.watch(poolPostIdsProvider(pool)),
        sliverHeaders: [
          SliverAppBar(
            title: const Text('pool.pool').tr(),
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Symbols.search),
                onPressed: () {
                  goToSearchPage(
                    context,
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
                pool.name.replaceAll('_', ' '),
                style: context.theme.textTheme.titleLarge,
              ),
              subtitle: Text(
                '${'pool.detail.last_updated'.tr()}: ${pool.updatedAt.fuzzify(locale: Localizations.localeOf(context))}',
              ),
            ),
          ),
          poolDesc.maybeWhen(
            data: (data) => data.description.isNotEmpty &&
                    hasTextBetweenDiv(data.description)
                ? SliverToBoxAdapter(
                    child: AppHtml(
                      onLinkTap: !config.hasStrictSFW
                          ? (url, attributes, element) => _onHtmlLinkTapped(
                                attributes,
                                url,
                                data.descriptionEndpointRefUrl,
                              )
                          : null,
                      data: data.description,
                    ),
                  )
                : const SliverSizedBox.shrink(),
            orElse: () => const SliverSizedBox.shrink(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  return PoolCategoryToggleSwitch(
                    onToggle: (order) {
                      ref
                          .read(selectedPoolDetailsOrderProvider.notifier)
                          .state = order;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        DanbooruPostGridController.of(context).refresh();
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _onHtmlLinkTapped(
  Map<String, String> attributes,
  String? url,
  String endpoint,
) {
  if (url == null) return;

  if (!attributes.containsKey('class')) return;
  final att = attributes['class']!.split(' ').toList();
  if (att.isEmpty) return;
  if (att.contains('dtext-external-link')) {
    launchExternalUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppWebView,
    );
  } else if (att.contains('dtext-wiki-link')) {
    launchExternalUrl(
      Uri.parse('$endpoint$url'),
      mode: LaunchMode.inAppWebView,
    );
    // ignore: no-empty-block
  } else if (att.contains('dtext-post-search-link')) {
// AppRouter.router.navigateTo(
//             context,
//             "/posts/search",
//             routeSettings: RouteSettings(arguments: [tag.rawName]),
//           )
  }
}

class PoolCategoryToggleSwitch extends StatelessWidget {
  const PoolCategoryToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(String order) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        initialValue: 'order',
        fixedWidth: 120,
        segments: {
          'order': 'Ordered',
          PoolDetailsOrder.latest.name: 'Latest',
          PoolDetailsOrder.oldest.name: 'Oldest',
        },
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}

class DanbooruInfinitePostIdList extends ConsumerStatefulWidget {
  const DanbooruInfinitePostIdList({
    super.key,
    required this.ids,
    this.sliverHeaders,
  });

  final List<int> ids;
  final List<Widget>? sliverHeaders;

  @override
  ConsumerState<DanbooruInfinitePostIdList> createState() =>
      _DanbooruInfinitePostIdListState();
}

class _DanbooruInfinitePostIdListState
    extends ConsumerState<DanbooruInfinitePostIdList> {
  List<int> paginate(List<int> ids, int page, int perPage) {
    final start = (page - 1) * perPage;
    var end = start + perPage;

    // if start is greater than the length of the list, return empty list
    if (start >= ids.length) {
      return [];
    }

    // if end is greater than the length of the list, set end to the length of the list
    if (end > ids.length) {
      end = ids.length;
    }

    return ids.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final perPage = ref.watch(
        imageListingSettingsProvider.select((value) => value.postsPerPage));
    final repo = ref.watch(danbooruPostRepoProvider(ref.watchConfigSearch));

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => TaskEither.Do(
          ($) async {
            final ids = paginate(widget.ids, page, perPage);
            if (ids.isEmpty) {
              return <DanbooruPost>[].toResult(
                total: widget.ids.length,
              );
            }

            final idString = ids.join(',');
            final posts = await $(repo.getPosts('id:$idString', 1));

            // sort the posts based on the order of the ids
            final ordered = <DanbooruPost>[];

            for (final id in ids) {
              final post =
                  posts.posts.firstWhereOrNull((post) => post.id == id);
              if (post != null) {
                ordered.add(post);
              }
            }

            return ordered.toResult(
              total: widget.ids.length,
            );
          },
        ),
        builder: (context, controller) => DanbooruPostGridController(
          controller: controller,
          child: PostGrid(
            controller: controller,
            itemBuilder:
                (context, index, multiSelectController, scrollController) =>
                    DefaultDanbooruImageGridItem(
              index: index,
              multiSelectController: multiSelectController,
              autoScrollController: scrollController,
              controller: controller,
            ),
            sliverHeaders: [
              if (widget.sliverHeaders != null) ...widget.sliverHeaders!,
            ],
          ),
        ),
      ),
    );
  }
}

// InheritedWidget to provide danbooru post grid controller to its children
class DanbooruPostGridController extends InheritedWidget {
  const DanbooruPostGridController({
    super.key,
    required this.controller,
    required super.child,
  });

  final PostGridController<DanbooruPost> controller;

  static PostGridController<DanbooruPost> of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<DanbooruPostGridController>();

    if (provider == null) {
      throw Exception('DanbooruPostGridControllerProvider not found');
    }

    return provider.controller;
  }

  @override
  bool updateShouldNotify(DanbooruPostGridController oldWidget) {
    return controller != oldWidget.controller;
  }
}
