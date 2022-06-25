// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({
    Key? key,
    required this.artistName,
    required this.backgroundImageUrl,
  }) : super(key: key);

  final String artistName;
  final String backgroundImageUrl;

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final RefreshController refreshController = RefreshController();
  final AutoScrollController scrollController = AutoScrollController();

  @override
  void dispose() {
    refreshController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height - 24;

    return Scaffold(
      body: SlidingUpPanel(
        scrollController: scrollController,
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        maxHeight: height,
        minHeight: height * 0.55,
        panelBuilder: (_) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: BlocBuilder<PostBloc, PostState>(
              buildWhen: (previous, current) => !current.hasMore,
              builder: (context, state) {
                return InfiniteLoadList(
                  scrollController: scrollController,
                  refreshController: refreshController,
                  enableLoadMore: state.hasMore,
                  onLoadMore: () => context
                      .read<PostBloc>()
                      .add(PostFetched(tags: widget.artistName)),
                  onRefresh: (controller) {
                    context
                        .read<PostBloc>()
                        .add(PostRefreshed(tag: widget.artistName));
                    Future.delayed(const Duration(milliseconds: 500),
                        () => controller.refreshCompleted());
                  },
                  builder: (context, controller) => CustomScrollView(
                    controller: controller,
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 10),
                        sliver: SliverToBoxAdapter(
                          child: CategoryToggleSwitch(
                            onToggle: (category) => context
                                .read<PostBloc>()
                                .add(
                                  PostRefreshed(
                                    tag: widget.artistName,
                                    order:
                                        _artistCategoryToPostsOrder(category),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        sliver: BlocBuilder<PostBloc, PostState>(
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
                                onTap: (post, index) =>
                                    AppRouter.router.navigateTo(
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
                      BlocBuilder<PostBloc, PostState>(
                        builder: (context, state) {
                          if (state.status == LoadStatus.loading) {
                            return const SliverPadding(
                              padding: EdgeInsets.only(bottom: 20, top: 20),
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
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.backgroundImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black.withOpacity(0.6)],
                  end: Alignment.topCenter,
                  begin: Alignment.bottomCenter,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.artistName.removeUnderscoreWithSpace(),
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                  ),
                  BlocBuilder<ArtistCubit, AsyncLoadState<Artist>>(
                    builder: _buildArtistAltNameTags,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArtistAltNameTags(
      BuildContext context, AsyncLoadState<Artist> state) {
    switch (state.status) {
      case LoadStatus.success:
        return Tags(
          heightHorizontalScroll: 40,
          spacing: 2,
          horizontalScroll: true,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          itemCount: state.data!.otherNames.length,
          itemBuilder: (index) {
            return Chip(
              shape: const StadiumBorder(side: BorderSide(color: Colors.grey)),
              padding: const EdgeInsets.all(4),
              labelPadding: const EdgeInsets.all(1),
              visualDensity: VisualDensity.compact,
              label: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85),
                child: Text(
                  state.data!.otherNames[index].removeUnderscoreWithSpace(),
                  overflow: TextOverflow.fade,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

enum ArtistCategory {
  popular,
  newest,
}

PostsOrder _artistCategoryToPostsOrder(ArtistCategory category) {
  if (category == ArtistCategory.popular) return PostsOrder.popular;
  return PostsOrder.newest;
}

class CategoryToggleSwitch extends StatelessWidget {
  const CategoryToggleSwitch({
    Key? key,
    required this.onToggle,
  }) : super(key: key);

  final void Function(ArtistCategory category) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleSwitch(
        customTextStyles: const [
          TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          TextStyle(fontWeight: FontWeight.w700),
        ],
        minWidth: 80,
        minHeight: 30,
        cornerRadius: 5,
        labels: const ['New', 'Popular'],
        activeBgColor: [Theme.of(context).colorScheme.primary],
        inactiveBgColor: Theme.of(context).colorScheme.background,
        borderWidth: 1,
        borderColor: [Theme.of(context).colorScheme.onBackground],
        onToggle: (index) => index == 0
            ? onToggle(ArtistCategory.newest)
            : onToggle(ArtistCategory.popular),
      ),
    );
  }
}
