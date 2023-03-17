// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/shared/default_post_context_menu.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_post_bloc.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_post_context_menu.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_sliver_post_grid.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/application/theme/theme_bloc.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/networking/networking.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'package:boorusama/core/ui/widgets/network_unavailable_indicator.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class GelbooruHomePage extends StatefulWidget {
  const GelbooruHomePage({
    super.key,
  });

  @override
  State<GelbooruHomePage> createState() => _GelbooruHomePageState();
}

class _GelbooruHomePageState extends State<GelbooruHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final AutoScrollController _autoScrollController = AutoScrollController();

  void _sendRefresh(String tag) =>
      context.read<GelbooruPostBloc>().add(GelbooruPostBlocRefreshed(
            tag: tag,
          ));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: state.theme == ThemeMode.light
                ? Brightness.dark
                : Brightness.light,
          ),
          child: Scaffold(
            extendBody: true,
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            body: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      BlocBuilder<NetworkBloc, NetworkState>(
                        builder: (_, state) => ConditionalRenderWidget(
                          condition: state is NetworkDisconnectedState ||
                              state is NetworkInitialState,
                          childBuilder: (_) =>
                              const NetworkUnavailableIndicator(),
                        ),
                      ),
                      Expanded(
                        child: BlocBuilder<GelbooruPostBloc, GelbooruPostState>(
                          buildWhen: (previous, current) => !current.hasMore,
                          builder: (context, state) {
                            return InfiniteLoadList(
                              extendBody:
                                  Screen.of(context).size == ScreenSize.small,
                              enableLoadMore: state.hasMore,
                              onLoadMore: () => context
                                  .read<GelbooruPostBloc>()
                                  .add(const GelbooruPostBlocFetched(
                                    tag: '',
                                  )),
                              onRefresh: (controller) {
                                _sendRefresh('');
                                Future.delayed(
                                  const Duration(seconds: 1),
                                  () => controller.refreshCompleted(),
                                );
                              },
                              scrollController: _autoScrollController,
                              builder: (context, controller) =>
                                  CustomScrollView(
                                controller: controller,
                                slivers: [
                                  // _buildAppBar(context),

                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    sliver: BlocSelector<SettingsCubit,
                                        SettingsState, GridSize>(
                                      selector: (state) =>
                                          state.settings.gridSize,
                                      builder: (context, gridSize) {
                                        return BlocBuilder<GelbooruPostBloc,
                                            GelbooruPostState>(
                                          buildWhen: (previous, current) =>
                                              !current.loading,
                                          builder: (context, state) {
                                            if (state.data.isEmpty &&
                                                !state.refreshing) {
                                              return SliverPostGridPlaceHolder(
                                                gridSize: gridSize,
                                              );
                                            } else if (state.data.isNotEmpty) {
                                              return GelbooruSliverPostGrid(
                                                posts: state.data.toList(),
                                                scrollController: controller,
                                                gridSize: gridSize,
                                                borderRadius:
                                                    _gridSizeToBorderRadius(
                                                  gridSize,
                                                ),
                                                // ignore: no-empty-block
                                                onTap: (post, index) {
                                                  // goToDetailPage(
                                                  //   context: context,
                                                  //   posts: state.posts,
                                                  //   initialIndex: index,
                                                  //   scrollController: controller,
                                                  //   postBloc: context.read<PostBloc>(),
                                                  // );
                                                },
                                                // ignore: no-empty-block
                                                onFavoriteUpdated:
                                                    (postId, value) {},
                                                contextMenuBuilder: (post) =>
                                                    GelbooruPostContextMenu(
                                                  post: post,
                                                ),
                                              );
                                            } else if (state.loading) {
                                              return const SliverToBoxAdapter(
                                                child: SizedBox.shrink(),
                                              );
                                            } else {
                                              return const SliverToBoxAdapter(
                                                child: ErrorBox(),
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  BlocBuilder<GelbooruPostBloc,
                                      GelbooruPostState>(
                                    builder: (context, state) {
                                      return state.loading
                                          ? const SliverPadding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 20,
                                              ),
                                              sliver: SliverToBoxAdapter(
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

BorderRadius _gridSizeToBorderRadius(GridSize size) {
  switch (size) {
    case GridSize.small:
      return const BorderRadius.all(Radius.circular(3));
    // case GridSize.large:
    //   return const BorderRadius.only(
    //     topLeft: Radius.circular(8),
    //     topRight: Radius.circular(8),
    //   );
    case GridSize.normal:
    case GridSize.large:
      return const BorderRadius.all(Radius.circular(8));
  }
}
