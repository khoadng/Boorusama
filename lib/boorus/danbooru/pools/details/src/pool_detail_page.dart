// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../../core/bulk_downloads/routes.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/html.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../../../foundation/utils/html_utils.dart';
import '../../../configs/providers.dart';
import '../../../posts/post/types.dart';
import '../../pool/types.dart';
import 'providers/providers.dart';
import 'types/query_utils.dart';
import 'widgets/danbooru_infinite_post_id_list.dart';
import 'widgets/pool_category_toggle_switch.dart';

class PoolDetailPage extends ConsumerWidget {
  const PoolDetailPage({
    required this.pool,
    super.key,
  });

  final DanbooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolDesc = ref.watch(poolDescriptionProvider(pool.id));
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));

    return CustomContextMenuOverlay(
      child: DanbooruInfinitePostIdList(
        ids: ref.watch(poolPostIdsProvider(pool)),
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
                pool.name.replaceAll('_', ' '),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                '${context.t.pool.detail.last_updated}: ${pool.updatedAt.fuzzify(locale: Localizations.localeOf(context))}',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            sliver: poolDesc.maybeWhen(
              data: (data) =>
                  data.description.isNotEmpty &&
                      hasTextBetweenDiv(data.description)
                  ? SliverToBoxAdapter(
                      child: AppHtml(
                        onLinkTap: !loginDetails.hasStrictSFW
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
          ),
          const _ToggleSwitch(),
        ],
      ),
    );
  }
}

class _ToggleSwitch extends ConsumerWidget {
  const _ToggleSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      sliver: SliverToBoxAdapter(
        child: PoolCategoryToggleSwitch(
          onToggle: (order) {
            ref.read(selectedPoolDetailsOrderProvider.notifier).state = order;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              PostScope.of<DanbooruPost>(context).refresh();
            });
          },
        ),
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
