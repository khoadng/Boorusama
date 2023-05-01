// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:boorusama/core/utils.dart';

class PoolDetailPage extends StatefulWidget {
  const PoolDetailPage({
    super.key,
    required this.pool,
    required this.postIds,
  });

  final Pool pool;
  final Queue<int> postIds;

  @override
  State<PoolDetailPage> createState() => _PoolDetailPageState();
}

class _PoolDetailPageState extends State<PoolDetailPage>
    with DanbooruPostTransformMixin, DanbooruPostServiceProviderMixin {
  final RefreshController refreshController = RefreshController();
  late final controller = PostGridController<DanbooruPost>(
    fetcher: (page) => context
        .read<DanbooruPostRepository>()
        .getPosts(
          'pool:${widget.pool.id}',
          page,
        )
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then(transform),
    refresher: () => context
        .read<DanbooruPostRepository>()
        .getPosts(
          'pool:${widget.pool.id}',
          1,
        )
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then(transform),
  );

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DanbooruInfinitePostList(
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
                  ['pool:${widget.pool.id}'],
                );
              },
              icon: const Icon(Icons.download),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(
              widget.pool.name.removeUnderscoreWithSpace(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              '${'pool.detail.last_updated'.tr()}: ${dateTimeToStringTimeAgo(
                widget.pool.updatedAt,
                locale: Localizations.localeOf(context).languageCode,
              )}',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: BlocBuilder<PoolDescriptionBloc, PoolDescriptionState>(
            builder: (context, state) {
              return state.status == LoadStatus.success &&
                      state.description.isNotEmpty
                  ? Html(
                      onLinkTap: (url, context, attributes, element) =>
                          _onHtmlLinkTapped(
                        attributes,
                        url,
                        state.descriptionEndpointRefUrl,
                      ),
                      data: state.description,
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
      ],
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
