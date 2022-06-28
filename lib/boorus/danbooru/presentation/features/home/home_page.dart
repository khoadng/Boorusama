// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api.dart';
import 'package:boorusama/boorus/danbooru/application/networking/networking.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/pool/pool_page.dart';
import 'package:boorusama/core/presentation/widgets/animated_indexed_stack.dart';
import 'package:boorusama/main.dart';
import 'bottom_bar_widget.dart';
import 'latest/latest_posts_view.dart';
import 'side_bar.dart';

class HomePage extends HookWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bottomTabIndex = useState(0);

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
                          return const Material(
                            color: Colors.black,
                            child: Text('Network unavailable'),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    Expanded(
                      child: AnimatedIndexedStack(
                        index: bottomTabIndex.value,
                        children: [
                          BlocBuilder<ApiCubit, ApiState>(
                            builder: (context, state) {
                              final postBloc = PostBloc(
                                postRepository: context.read<IPostRepository>(),
                                blacklistedTagsRepository:
                                    context.read<BlacklistedTagsRepository>(),
                              )..add(const PostRefreshed());

                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: postBloc),
                                ],
                                child: LatestView(
                                  onMenuTap: () =>
                                      scaffoldKey.currentState!.openDrawer(),
                                ),
                              );
                            },
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
