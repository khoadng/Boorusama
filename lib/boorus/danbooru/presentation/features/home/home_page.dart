// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/pool/pool_page.dart';
import 'package:boorusama/core/application/networking/networking.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/presentation/network_unavailable_indicator.dart';
import 'package:boorusama/core/presentation/widgets/animated_indexed_stack.dart';
import 'package:boorusama/core/presentation/widgets/conditional_render_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenSize = screenWidthToDisplaySize(size.width);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: state.theme == ThemeMode.light
                ? Brightness.dark
                : Brightness.light,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Scaffold(
              extendBody: true,
              key: scaffoldKey,
              drawer: screenSize == ScreenSize.small
                  ? const SideBarMenu(popOnSelect: true)
                  : null,
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    if (screenSize != ScreenSize.small)
                      ValueListenableBuilder<int>(
                        valueListenable: viewIndex,
                        builder: (context, index, _) => SideBarMenu(
                          initialContentBuilder: (context) => screenSize !=
                                  ScreenSize.small
                              ?
                              //TODO: create a widget to manage this, also stop using index as a selected indicator
                              [
                                  ListTile(
                                    selected: index == 0,
                                    leading: index == 0
                                        ? const Icon(Icons.dashboard)
                                        : const Icon(Icons.dashboard_outlined),
                                    title: const Text('Home'),
                                    onTap: () => viewIndex.value = 0,
                                  ),
                                  ListTile(
                                    selected: index == 1,
                                    leading: index == 1
                                        ? const Icon(Icons.explore)
                                        : const Icon(Icons.explore_outlined),
                                    title: const Text('Explore'),
                                    onTap: () => viewIndex.value = 1,
                                  ),
                                  ListTile(
                                    selected: index == 2,
                                    leading: index == 2
                                        ? const Icon(Icons.photo_album)
                                        : const Icon(
                                            Icons.photo_album_outlined),
                                    title: const Text('Pool'),
                                    onTap: () => viewIndex.value = 2,
                                  ),
                                ]
                              : null,
                        ),
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
                                  LatestView(
                                    onMenuTap: () =>
                                        scaffoldKey.currentState!.openDrawer(),
                                  ),
                                  const ExplorePage(),
                                  MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) => PoolBloc(
                                          poolRepository:
                                              context.read<PoolRepository>(),
                                          postRepository:
                                              context.read<IPostRepository>(),
                                        )..add(const PoolRefreshed(
                                            category: PoolCategory.series,
                                            order: PoolOrder.latest,
                                          )),
                                      ),
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
              ),
              bottomNavigationBar: screenSize == ScreenSize.small
                  ? BottomBar(
                      initialValue: viewIndex.value,
                      onTabChanged: (value) => viewIndex.value = value,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
