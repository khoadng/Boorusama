// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/networking/network_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/pool/pool_page.dart';
import 'package:boorusama/core/presentation/widgets/animated_indexed_stack.dart';
import 'package:boorusama/main.dart';
import 'bottom_bar_widget.dart';
import 'explore/explore_page.dart';
import 'latest/latest_posts_view.dart';
import 'side_bar.dart';

class HomePage extends HookWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bottomTabIndex = useState(0);

    return Column(
      children: <Widget>[
        BlocBuilder<NetworkBloc, NetworkState>(
          builder: (context, state) {
            if (state is NetworkConnectedState) {
              return const SizedBox.shrink();
            } else if (state is NetworkDisconnectedState) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.black,
                  child: Text('Network unavailable'),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        Expanded(
          child: BlocBuilder<ThemeBloc, ThemeState>(
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
                      child: AnimatedIndexedStack(
                        index: bottomTabIndex.value,
                        children: <Widget>[
                          MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (context) => PostBloc(
                                        postRepository: RepositoryProvider.of<
                                            IPostRepository>(context),
                                        blacklistedTagsRepository: context
                                            .read<BlacklistedTagsRepository>(),
                                      )..add(const PostRefreshed())),
                            ],
                            child: LatestView(
                              onMenuTap: () =>
                                  scaffoldKey.currentState!.openDrawer(),
                            ),
                          ),
                          const ExplorePage(),
                          const PoolPage(),
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
          ),
        ),
      ],
    );
  }
}
