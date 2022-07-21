// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/networking/networking.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/pool/pool_page.dart';
import 'package:boorusama/core/presentation/widgets/animated_indexed_stack.dart';
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
  final bottomTabIndex = ValueNotifier(0);

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
                child: Column(
                  children: [
                    BlocBuilder<NetworkBloc, NetworkState>(
                      builder: (context, state) {
                        if (state is NetworkConnectedState) {
                          return const SizedBox.shrink();
                        } else if (state is NetworkDisconnectedState) {
                          return Material(
                            color: Colors.black,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.wifi_off,
                                  size: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: const Text('network.unavailable').tr(),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: bottomTabIndex,
                        builder: (context, index, _) => AnimatedIndexedStack(
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
                                      order: PoolOrder.latest)),
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
              bottomNavigationBar: BottomBar(
                onTabChanged: (value) => bottomTabIndex.value = value,
              ),
            ),
          ),
        );
      },
    );
  }
}
