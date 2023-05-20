// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/utils.dart';

class PoolDetailPage extends ConsumerWidget {
  const PoolDetailPage({
    super.key,
    required this.pool,
    required this.postIds,
  });

  final Pool pool;
  final Queue<int> postIds;

  static Widget of(
    BuildContext context, {
    required Pool pool,
  }) {
    return DanbooruProvider.of(
      context,
      builder: (dcontext) => CustomContextMenuOverlay(
        child: PoolDetailPage(
          pool: pool,
          postIds: QueueList.from(pool.postIds.reversed.skip(20)),
        ),
      ),
    );
  }

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
                '${'pool.detail.last_updated'.tr()}: ${dateTimeToStringTimeAgo(
                  pool.updatedAt,
                  locale: Localizations.localeOf(context).languageCode,
                )}',
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
