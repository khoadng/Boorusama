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
import 'package:boorusama/boorus/danbooru/domain/pools/pool.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';

class PoolDetailPage extends StatefulWidget {
  const PoolDetailPage({
    Key? key,
    required this.pool,
  }) : super(key: key);

  final Pool pool;

  @override
  State<PoolDetailPage> createState() => _PoolDetailPageState();
}

class _PoolDetailPageState extends State<PoolDetailPage> {
  final RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    context.read<PoolDescriptionCubit>().getDescription(widget.pool.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pool.pool').tr(),
      ),
      body: SafeArea(child: BlocBuilder<PoolDetailCubit, PoolDetailState>(
        builder: (context, state) {
          return InfiniteLoadList(
            refreshController: refreshController,
            enableRefresh: false,
            onLoadMore: () => context.read<PoolDetailCubit>().load(),
            builder: (context, controller) => CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: ListTile(
                    title: Text(
                      widget.pool.name.removeUnderscoreWithSpace(),
                      style: Theme.of(context).textTheme.headline6!,
                    ),
                    subtitle: Text(
                        '${'pool.detail.last_updated'.tr()}: ${dateTimeToStringTimeAgo(
                      widget.pool.updatedAt,
                      locale: Localizations.localeOf(context).languageCode,
                    )}'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<PoolDescriptionCubit,
                      AsyncLoadState<PoolDescriptionState>>(
                    builder: (context, state) {
                      if (state.status == LoadStatus.success) {
                        return Html(
                          onLinkTap: (url, context, attributes, element) =>
                              _onHtmlLinkTapped(attributes, url,
                                  state.data!.descriptionEndpointRefUrl),
                          data: state.data!.description,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: BlocBuilder<PoolDetailCubit, PoolDetailState>(
                    buildWhen: (previous, current) =>
                        current.status != LoadStatus.loading,
                    builder: (context, state) {
                      if (state.status == LoadStatus.initial) {
                        return const SliverPostGridPlaceHolder();
                      } else if (state.status == LoadStatus.success) {
                        if (state.posts.isEmpty) {
                          return const SliverToBoxAdapter(
                              child: Center(child: Text('No data')));
                        }
                        return SliverPostGrid(
                          posts: state.posts,
                          scrollController: controller,
                          onTap: (post, index) => AppRouter.router.navigateTo(
                            context,
                            '/post/detail',
                            routeSettings: RouteSettings(
                              arguments: [
                                state.posts,
                                index,
                                controller,
                              ],
                            ),
                          ),
                        );
                      } else if (state.status == LoadStatus.loading) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      } else {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Text('Something went wrong'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                BlocBuilder<PoolDetailCubit, PoolDetailState>(
                  builder: (context, state) {
                    if (state.status == LoadStatus.loading) {
                      return const SliverPadding(
                        padding: EdgeInsets.only(bottom: 20, top: 60),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    } else {
                      return const SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      )),
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
  } else if (att.contains('dtext-post-search-link')) {
// AppRouter.router.navigateTo(
//             context,
//             "/posts/search",
//             routeSettings: RouteSettings(arguments: [tag.rawName]),
//           )
  }
}
