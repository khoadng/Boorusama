// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_page.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/ui/network_indicator_with_network_bloc.dart';
import 'package:boorusama/core/ui/widgets/animated_indexed_stack.dart';
import 'bottom_bar_widget.dart';
import 'side_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

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
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            theme == ThemeMode.light ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
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
                builder: (context, index, _) => ValueListenableBuilder<bool>(
                  valueListenable: expanded,
                  builder: (context, value, _) => value
                      ? SideBarMenu(
                          initialContentBuilder: (context) => screenSize !=
                                  ScreenSize.small
                              ?
                              //TODO: create a widget to manage this, also stop using index as a selected indicator
                              [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: IconButton(
                                      onPressed: () => _onMenuTap(screenSize),
                                      icon: const Icon(Icons.menu),
                                    ),
                                  ),
                                  _NavigationTile(
                                    value: 0,
                                    index: index,
                                    selectedIcon: const Icon(Icons.dashboard),
                                    icon: const Icon(
                                      Icons.dashboard_outlined,
                                    ),
                                    title: const Text('Home'),
                                    onTap: (value) => viewIndex.value = value,
                                  ),
                                  _NavigationTile(
                                    value: 1,
                                    index: index,
                                    selectedIcon: const Icon(Icons.explore),
                                    icon: const Icon(Icons.explore_outlined),
                                    title: const Text('Explore'),
                                    onTap: (value) => viewIndex.value = value,
                                  ),
                                  _NavigationTile(
                                    value: 2,
                                    index: index,
                                    selectedIcon: const Icon(Icons.photo_album),
                                    icon: const Icon(
                                      Icons.photo_album_outlined,
                                    ),
                                    title: const Text('Pool'),
                                    onTap: (value) => viewIndex.value = value,
                                  ),
                                ]
                              : null,
                        )
                      : ColoredBox(
                          color: Theme.of(context).colorScheme.background,
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).viewPadding.top,
                              ),
                              IconButton(
                                onPressed: () => _onMenuTap(screenSize),
                                icon: const Icon(Icons.menu),
                              ),
                              Expanded(
                                child: NavigationRail(
                                  minWidth: 60,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  onDestinationSelected: (value) =>
                                      viewIndex.value = value,
                                  destinations: [
                                    NavigationRailDestination(
                                      icon: index == 0
                                          ? const Icon(Icons.dashboard)
                                          : const Icon(
                                              Icons.dashboard_outlined,
                                            ),
                                      label: const Text('Home'),
                                    ),
                                    NavigationRailDestination(
                                      icon: index == 1
                                          ? const Icon(Icons.explore)
                                          : const Icon(
                                              Icons.explore_outlined,
                                            ),
                                      label: const Text('Explore'),
                                    ),
                                    NavigationRailDestination(
                                      icon: index == 2
                                          ? const Icon(Icons.photo_album)
                                          : const Icon(
                                              Icons.photo_album_outlined,
                                            ),
                                      label: const Text('Pool'),
                                    ),
                                  ],
                                  selectedIndex: index,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  const NetworkUnavailableIndicatorWithNetworkBloc(),
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: viewIndex,
                      builder: (context, index, _) => AnimatedIndexedStack(
                        index: index,
                        children: [
                          BlocProvider(
                            create: (context) => PostBloc.of(context)
                              ..add(const PostRefreshed(
                                fetcher: LatestPostFetcher(),
                              )),
                            child: _LatestView(
                              onMenuTap: () => _onMenuTap(screenSize),
                            ),
                          ),
                          BlocProvider.value(
                            value: context.read<ExploreBloc>(),
                            child: const _ExplorePage(),
                          ),
                          MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => PoolBloc(
                                  poolRepository:
                                      context.read<PoolRepository>(),
                                  postRepository:
                                      context.read<DanbooruPostRepository>(),
                                )..add(const PoolRefreshed(
                                    category: PoolCategory.series,
                                    order: PoolOrder.latest,
                                  )),
                              ),
                            ],
                            child: const _PoolPage(),
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
      ),
    );
  }

  void _onMenuTap(ScreenSize screenSize) {
    {
      if (screenSize == ScreenSize.small) {
        scaffoldKey.currentState!.openDrawer();
      } else {
        expanded.value = !expanded.value;
      }
    }
  }
}

class _ExplorePage extends StatelessWidget {
  const _ExplorePage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NetworkBloc>().state;

    return ExplorePage(
      useAppBarPadding: state is NetworkConnectedState,
    );
  }
}

class _PoolPage extends StatelessWidget {
  const _PoolPage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NetworkBloc>().state;

    return PoolPage(
      useAppBarPadding: state is NetworkConnectedState,
    );
  }
}

class _LatestView extends StatelessWidget {
  const _LatestView({
    required this.onMenuTap,
  });

  final void Function() onMenuTap;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NetworkBloc>().state;

    return LatestView(
      onMenuTap: onMenuTap,
      useAppBarPadding: state is NetworkConnectedState,
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.value,
    required this.index,
    required this.selectedIcon,
    required this.icon,
    required this.title,
    required this.onTap,
  });

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
