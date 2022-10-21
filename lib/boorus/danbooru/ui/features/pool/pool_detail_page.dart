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
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/fetchers/pool_post_fetcher.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pool.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/common/collection_utils.dart';
import 'package:boorusama/core/utils.dart';

class PoolDetailPage extends StatefulWidget {
  const PoolDetailPage({
    Key? key,
    required this.pool,
    required this.postIds,
  }) : super(key: key);

  final Pool pool;
  final Queue<int> postIds;

  @override
  State<PoolDetailPage> createState() => _PoolDetailPageState();
}

class _PoolDetailPageState extends State<PoolDetailPage> {
  final RefreshController refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pool.pool').tr(),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => PostBloc.of(context)
            ..add(
              PostRefreshed(
                fetcher: PoolPostFetcher(
                  postIds: widget.postIds.dequeue(20),
                ),
              ),
            ),
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              return InfiniteLoadList(
                refreshController: refreshController,
                enableRefresh: false,
                enableLoadMore: state.hasMore,
                onLoadMore: () => context.read<PostBloc>().add(
                      PostFetched(
                        tags: '',
                        fetcher: PoolPostFetcher(
                          postIds: widget.postIds.dequeue(20),
                        ),
                      ),
                    ),
                builder: (context, controller) => CustomScrollView(
                  controller: controller,
                  slivers: [
                    SliverToBoxAdapter(
                      child: ListTile(
                        title: Text(
                          widget.pool.name.removeUnderscoreWithSpace(),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(
                          '${'pool.detail.last_updated'.tr()}: ${dateTimeToStringTimeAgo(
                            widget.pool.updatedAt,
                            locale:
                                Localizations.localeOf(context).languageCode,
                          )}',
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: BlocBuilder<PoolDescriptionBloc,
                          PoolDescriptionState>(
                        builder: (context, state) {
                          return state.status == LoadStatus.success
                              ? Html(
                                  onLinkTap:
                                      (url, context, attributes, element) =>
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
                    HomePostGrid(
                      controller: controller,
                      usePlaceholder: false,
                    ),
                    BlocBuilder<PostBloc, PostState>(
                      builder: (context, state) {
                        return state.status == LoadStatus.loading
                            ? const SliverPadding(
                                padding: EdgeInsets.only(bottom: 20, top: 60),
                                sliver: SliverToBoxAdapter(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              )
                            : const SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
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
