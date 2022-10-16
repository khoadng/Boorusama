// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_page.dart';
import 'package:boorusama/core/application/networking/networking.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/ui/widgets/animated_indexed_stack.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'package:boorusama/core/ui/widgets/network_unavailable_indicator.dart';
import 'bottom_bar_widget.dart';
import 'side_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final viewIndex = ValueNotifier(0);
  final expanded = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final screenSize = Screen.of(context).size;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: state.theme == ThemeMode.light
                ? Brightness.dark
                : Brightness.light,
          ),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              final latestPostBloc = PostBloc.of(context)
                ..add(const PostRefreshed(fetcher: LatestPostFetcher()));

              final poolBloc = PoolBloc(
                poolRepository: context.read<PoolRepository>(),
                postRepository: context.read<PostRepository>(),
              )..add(const PoolRefreshed(
                  category: PoolCategory.series,
                  order: PoolOrder.latest,
                ));

              return Scaffold(
                extendBody: true,
                key: scaffoldKey,
                drawer: screenSize == ScreenSize.small
                    ? const SideBarMenu(
                        width: 300,
                        popOnSelect: true,
                        padding: EdgeInsets.zero,
                      )
                    : null,
                resizeToAvoidBottomInset: false,
                body: Row(
                  children: [
                    if (screenSize != ScreenSize.small)
                      ValueListenableBuilder<int>(
                        valueListenable: viewIndex,
                        builder: (context, index, _) => ValueListenableBuilder<
                                bool>(
                            valueListenable: expanded,
                            builder: (context, value, _) => value
                                ? SideBarMenu(
                                    initialContentBuilder: (context) =>
                                        screenSize != ScreenSize.small
                                            ?
                                            //TODO: create a widget to manage this, also stop using index as a selected indicator
                                            [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 6),
                                                  child: IconButton(
                                                    onPressed: () =>
                                                        _onMenuTap(screenSize),
                                                    icon:
                                                        const Icon(Icons.menu),
                                                  ),
                                                ),
                                                _NavigationTile(
                                                  value: 0,
                                                  index: index,
                                                  selectedIcon: const Icon(
                                                      Icons.dashboard),
                                                  icon: const Icon(
                                                      Icons.dashboard_outlined),
                                                  title: const Text('Home'),
                                                  onTap: (value) =>
                                                      viewIndex.value = value,
                                                ),
                                                _NavigationTile(
                                                  value: 1,
                                                  index: index,
                                                  selectedIcon:
                                                      const Icon(Icons.explore),
                                                  icon: const Icon(
                                                      Icons.explore_outlined),
                                                  title: const Text('Explore'),
                                                  onTap: (value) =>
                                                      viewIndex.value = value,
                                                ),
                                                _NavigationTile(
                                                  value: 2,
                                                  index: index,
                                                  selectedIcon: const Icon(
                                                      Icons.photo_album),
                                                  icon: const Icon(Icons
                                                      .photo_album_outlined),
                                                  title: const Text('Pool'),
                                                  onTap: (value) =>
                                                      viewIndex.value = value,
                                                ),
                                              ]
                                            : null,
                                  )
                                : Container(
                                    color: Theme.of(context).backgroundColor,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                .viewPadding
                                                .top),
                                        IconButton(
                                          onPressed: () =>
                                              _onMenuTap(screenSize),
                                          icon: const Icon(Icons.menu),
                                        ),
                                        Expanded(
                                          child: NavigationRail(
                                            minWidth: 60,
                                            backgroundColor: Theme.of(context)
                                                .backgroundColor,
                                            onDestinationSelected: (value) =>
                                                viewIndex.value = value,
                                            destinations: [
                                              NavigationRailDestination(
                                                icon: index == 0
                                                    ? const Icon(
                                                        Icons.dashboard)
                                                    : const Icon(Icons
                                                        .dashboard_outlined),
                                                label: const Text('Home'),
                                              ),
                                              NavigationRailDestination(
                                                icon: index == 1
                                                    ? const Icon(Icons.explore)
                                                    : const Icon(
                                                        Icons.explore_outlined),
                                                label: const Text('Explore'),
                                              ),
                                              NavigationRailDestination(
                                                icon: index == 2
                                                    ? const Icon(
                                                        Icons.photo_album)
                                                    : const Icon(Icons
                                                        .photo_album_outlined),
                                                label: const Text('Pool'),
                                              ),
                                            ],
                                            selectedIndex: index,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                      ),
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
                            child: ValueListenableBuilder<int>(
                              valueListenable: viewIndex,
                              builder: (context, index, _) =>
                                  AnimatedIndexedStack(
                                index: index,
                                children: [
                                  BlocProvider.value(
                                    value: latestPostBloc,
                                    child: LatestView(
                                      onMenuTap: screenSize == ScreenSize.small
                                          ? () => _onMenuTap(screenSize)
                                          : null,
                                    ),
                                  ),
                                  const ExplorePage(),
                                  MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(value: poolBloc),
                                    ],
                                    child: const PoolPage(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: screenSize == ScreenSize.small
                    ? BottomBar(
                        initialValue: viewIndex.value,
                        onTabChanged: (value) => viewIndex.value = value,
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _onMenuTap(ScreenSize screenSize) {
    {
      if (screenSize == ScreenSize.small) {
        scaffoldKey.currentState!.openDrawer();
      } else {
        if (expanded.value) {
          expanded.value = false;
        } else {
          expanded.value = true;
        }
      }
    }
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    Key? key,
    required this.value,
    required this.index,
    required this.selectedIcon,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final int value;
  final Widget selectedIcon;
  final Widget icon;
  final Widget title;
  final void Function(int value) onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: index == value ? Colors.grey[800] : Colors.transparent,
      child: InkWell(
        child: ListTile(
          textColor: index == value ? Colors.white : null,
          leading: index == value ? selectedIcon : icon,
          title: title,
          onTap: () => onTap(value),
        ),
      ),
    );
  }
}
