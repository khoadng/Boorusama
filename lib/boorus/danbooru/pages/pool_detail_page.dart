// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/utils/html_utils.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

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
      CustomContextMenuOverlay(
        child: PoolDetailPage(
          pool: pool,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolDesc = ref.watch(poolDescriptionProvider(pool.id));
    final config = ref.watchConfig;

    return PostScope(
      fetcher: (page) => ref.read(danbooruPostRepoProvider(config)).getPosts(
        ['pool:${pool.id}'],
        page,
      ),
      builder: (context, controller, errors) => DanbooruInfinitePostList(
        errors: errors,
        controller: controller,
        sliverHeaderBuilder: (context) => [
          SliverAppBar(
            title: const Text('pool.pool').tr(),
            floating: true,
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
                pool.name.replaceUnderscoreWithSpace(),
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
                    child: Html(
                      onLinkTap: !config.hasStrictSFW
                          ? (url, context, attributes, element) =>
                              _onHtmlLinkTapped(
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
