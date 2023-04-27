// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/application/popular/moebooru_popular_cubit.dart';
import 'package:boorusama/boorus/moebooru/application/posts/moebooru_post_cubit.dart';
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_popular_repository.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/boorus/moebooru/ui/home/moebooru_bottom_bar.dart';
import 'package:boorusama/boorus/moebooru/ui/popular/moebooru_popular_page.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/core/application/theme/theme_bloc.dart';
import 'package:boorusama/core/ui/network_indicator_with_network_bloc.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/widgets/animated_indexed_stack.dart';

class MoebooruHomePage extends StatefulWidget {
  const MoebooruHomePage({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  State<MoebooruHomePage> createState() => _MoebooruHomePageState();
}

class _MoebooruHomePageState extends State<MoebooruHomePage>
    with MoebooruPostCubitMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final AutoScrollController _autoScrollController = AutoScrollController();
  final viewIndex = ValueNotifier(0);

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
            body: Column(
              children: [
                const NetworkUnavailableIndicatorWithNetworkBloc(),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: viewIndex,
                    builder: (context, index, _) => AnimatedIndexedStack(
                      index: index,
                      children: [
                        BlocBuilder<MoebooruPostCubit, MoebooruPostState>(
                          builder: (context, state) {
                            return MoebooruInfinitePostList(
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
                                        goToMoebooruSearchPage(context),
                                  ),
                                  floating: true,
                                  snap: true,
                                  automaticallyImplyLeading: false,
                                ),
                              ],
                            );
                          },
                        ),
                        // BlocProvider.value(
                        //   value: context.read<ExploreBloc>(),
                        //   child: const _ExplorePage(),
                        // ),
                        BlocProvider(
                          create: (context) => MoebooruPopularPostCubit(
                            extra: MoebooruPopularPostExtra(
                              dateTime: DateTime.now(),
                              popularType: MoebooruPopularType.day,
                            ),
                            popularRepository:
                                context.read<MoebooruPopularRepository>(),
                          )..refresh(),
                          child: const MoebooruPopularPage(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: MoebooruBottomBar(
              initialValue: viewIndex.value,
              onTabChanged: (value) => viewIndex.value = value,
            ),
          ),
        );
      },
    );
  }
}
