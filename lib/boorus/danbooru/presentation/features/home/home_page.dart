// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:side_navigation/side_navigation.dart';

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
              drawer: const SideBarMenu(),
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    if (screenSize != ScreenSize.small)
                      ValueListenableBuilder<int>(
                        valueListenable: viewIndex,
                        builder: (context, index, _) => SideNavigationBar(
                          selectedIndex: index,
                          items: const [
                            SideNavigationBarItem(
                              icon: Icons.dashboard,
                              label: 'Home',
                            ),
                            SideNavigationBarItem(
                              icon: Icons.explore,
                              label: 'Explore',
                            ),
                            SideNavigationBarItem(
                              icon: FontAwesomeIcons.images,
                              label: 'Pool',
                            ),
                          ],
                          onTap: (index) => viewIndex.value = index,
                          toggler: SideBarToggler(
                              expandIcon: Icons.keyboard_arrow_left,
                              shrinkIcon: Icons.keyboard_arrow_right,
                              onToggle: () {}),
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
