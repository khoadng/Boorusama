// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores/explore_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_page.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/ui/network_indicator_with_network_bloc.dart';
import 'package:boorusama/core/ui/widgets/animated_indexed_stack.dart';
import 'bottom_bar_widget.dart';
import 'other_features_page.dart';

class DanbooruHomePage extends StatefulWidget {
  const DanbooruHomePage({
    super.key,
  });

  @override
  State<DanbooruHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<DanbooruHomePage> {
  final viewIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            theme == ThemeMode.light ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
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
                    BlocProvider(
                      create: (context) => PostBloc.of(context)
                        ..add(const PostRefreshed(
                          fetcher: LatestPostFetcher(),
                        )),
                      child: _LatestView(
                        onMenuTap: () => {},
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
                            poolRepository: context.read<PoolRepository>(),
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
                    const OtherFeaturesPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomBar(
          initialValue: viewIndex.value,
          onTabChanged: (value) => viewIndex.value = value,
        ),
      ),
    );
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
