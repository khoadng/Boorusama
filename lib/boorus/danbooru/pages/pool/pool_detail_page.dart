// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/features/posts/app.dart';
import 'package:boorusama/boorus/danbooru/pages/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/utils/time_utils.dart';

class PoolDetailPage extends ConsumerWidget {
  const PoolDetailPage({
    super.key,
    required this.pool,
  });

  final Pool pool;

  static Widget of(
    BuildContext context, {
    required Pool pool,
  }) =>
      DanbooruProvider(
        builder: (_) => CustomContextMenuOverlay(
          child: PoolDetailPage(
            pool: pool,
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolDesc = ref.watch(poolDescriptionProvider(pool.id));

    return DanbooruPostScope(
      fetcher: (page) => ref.read(danbooruPostRepoProvider).getPosts(
            'pool:${pool.id}',
            page,
          ),
      builder: (context, controller, errors) => DanbooruInfinitePostList(
        errors: errors,
        controller: controller,
        sliverHeaderBuilder: (context) => [
          SliverAppBar(
            title: const Text('pool.pool').tr(),
            floating: true,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              IconButton(
                onPressed: () {
                  goToBulkDownloadPage(
                    context,
                    ['pool:${pool.id}'],
                    ref: ref,
                  );
                },
                icon: const Icon(Icons.download),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(
                pool.name.removeUnderscoreWithSpace(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                '${'pool.detail.last_updated'.tr()}: ${pool.updatedAt.fuzzify(locale: Localizations.localeOf(context))}',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: poolDesc.description.isNotEmpty
                ? Html(
                    onLinkTap: (url, context, attributes, element) =>
                        _onHtmlLinkTapped(
                      attributes,
                      url,
                      poolDesc.descriptionEndpointRefUrl,
                    ),
                    data: poolDesc.description,
                  )
                : const SizedBox.shrink(),
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
