// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_cubit.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_infinite_post_list.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/theme/theme_bloc.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'package:boorusama/core/ui/widgets/network_unavailable_indicator.dart';

class GelbooruHomePage extends StatefulWidget {
  const GelbooruHomePage({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  State<GelbooruHomePage> createState() => _GelbooruHomePageState();
}

class _GelbooruHomePageState extends State<GelbooruHomePage>
    with GelbooruPostCubitMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final AutoScrollController _autoScrollController = AutoScrollController();

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
                        child:
                            BlocBuilder<GelbooruPostCubit, GelbooruPostState>(
                          builder: (context, state) {
                            return GelbooruInfinitePostList(
                              refreshing: state.refreshing,
                              loading: state.loading,
                              hasMore: state.hasMore,
                              error: state.error,
                              data: state.data,
                              onLoadMore: fetch,
                              onRefresh: () => refresh(),
                              scrollController: _autoScrollController,
                              sliverHeaderBuilder: (context) => [
                                SliverAppBar(
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  toolbarHeight: kToolbarHeight * 1.2,
                                  title: SearchBar(
                                    enabled: false,
                                    leading: widget.onMenuTap != null
                                        ? IconButton(
                                            icon: const Icon(Icons.menu),
                                            onPressed: () =>
                                                widget.onMenuTap?.call(),
                                          )
                                        : null,
                                    onTap: () =>
                                        goToGelbooruSearchPage(context),
                                  ),
                                  floating: true,
                                  snap: true,
                                  automaticallyImplyLeading: false,
                                ),
                              ],
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
