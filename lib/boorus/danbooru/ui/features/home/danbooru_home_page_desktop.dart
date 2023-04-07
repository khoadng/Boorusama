// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores/explore_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_page.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/posts/post_cubit.dart';
import 'package:boorusama/core/ui/widgets/animated_indexed_stack.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'package:boorusama/core/ui/widgets/network_unavailable_indicator.dart';
import '../../../../../core/ui/home/side_bar_menu.dart';
import 'latest_posts_view_desktop.dart';

class DanbooruHomePageDesktop extends StatefulWidget {
  const DanbooruHomePageDesktop({
    super.key,
  });

  @override
  State<DanbooruHomePageDesktop> createState() =>
      _DanbooruHomePageDesktopState();
}

class _DanbooruHomePageDesktopState extends State<DanbooruHomePageDesktop> {
  final viewIndex = ValueNotifier(0);
  final expanded = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return Container();

    // return Scaffold(
    //   body: Row(
    //     children: [
    //       ValueListenableBuilder<int>(
    //         valueListenable: viewIndex,
    //         builder: (context, index, _) => ValueListenableBuilder<bool>(
    //           valueListenable: expanded,
    //           builder: (context, value, _) => value
    //               ? SideBarMenu(
    //                   initialContentBuilder: (context) =>
    //                       //TODO: create a widget to manage this, also stop using index as a selected indicator
    //                       [
    //                     Padding(
    //                       padding: const EdgeInsets.only(left: 6),
    //                       child: IconButton(
    //                         onPressed: () => _onMenuTap(),
    //                         icon: const Icon(Icons.menu),
    //                       ),
    //                     ),
    //                     _NavigationTile(
    //                       value: 0,
    //                       index: index,
    //                       selectedIcon: const Icon(Icons.dashboard),
    //                       icon: const Icon(
    //                         Icons.dashboard_outlined,
    //                       ),
    //                       title: const Text('Home'),
    //                       onTap: (value) => viewIndex.value = value,
    //                     ),
    //                     _NavigationTile(
    //                       value: 1,
    //                       index: index,
    //                       selectedIcon: const Icon(Icons.explore),
    //                       icon: const Icon(Icons.explore_outlined),
    //                       title: const Text('Explore'),
    //                       onTap: (value) => viewIndex.value = value,
    //                     ),
    //                     _NavigationTile(
    //                       value: 2,
    //                       index: index,
    //                       selectedIcon: const Icon(Icons.photo_album),
    //                       icon: const Icon(
    //                         Icons.photo_album_outlined,
    //                       ),
    //                       title: const Text('Pool'),
    //                       onTap: (value) => viewIndex.value = value,
    //                     ),
    //                   ],
    //                 )
    //               : ColoredBox(
    //                   color: Theme.of(context).colorScheme.background,
    //                   child: Column(
    //                     children: [
    //                       SizedBox(
    //                         height: MediaQuery.of(context).viewPadding.top,
    //                       ),
    //                       IconButton(
    //                         onPressed: () => _onMenuTap(),
    //                         icon: const Icon(Icons.menu),
    //                       ),
    //                       Expanded(
    //                         child: NavigationRail(
    //                           minWidth: 60,
    //                           backgroundColor:
    //                               Theme.of(context).colorScheme.background,
    //                           onDestinationSelected: (value) =>
    //                               viewIndex.value = value,
    //                           destinations: [
    //                             NavigationRailDestination(
    //                               icon: index == 0
    //                                   ? const Icon(Icons.dashboard)
    //                                   : const Icon(
    //                                       Icons.dashboard_outlined,
    //                                     ),
    //                               label: const Text('Home'),
    //                             ),
    //                             NavigationRailDestination(
    //                               icon: index == 1
    //                                   ? const Icon(Icons.explore)
    //                                   : const Icon(
    //                                       Icons.explore_outlined,
    //                                     ),
    //                               label: const Text('Explore'),
    //                             ),
    //                             NavigationRailDestination(
    //                               icon: index == 2
    //                                   ? const Icon(Icons.photo_album)
    //                                   : const Icon(
    //                                       Icons.photo_album_outlined,
    //                                     ),
    //                               label: const Text('Pool'),
    //                             ),
    //                           ],
    //                           selectedIndex: index,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //         ),
    //       ),
    //       Expanded(
    //         child: Column(
    //           children: [
    //             const _NetworkUnavailableIndicator(),
    //             Expanded(
    //               child: ValueListenableBuilder<int>(
    //                 valueListenable: viewIndex,
    //                 builder: (context, index, _) => AnimatedIndexedStack(
    //                   index: index,
    //                   children: [
    //                     BlocProvider(
    //                       create: (context) =>
    //                           DanbooruPostCubit.of(context, tags: () {})
    //                             ..add(const PostRefreshed(
    //                               fetcher: LatestPostFetcher(),
    //                             )),
    //                       child: const LatestViewDesktop(),
    //                     ),
    //                     BlocProvider.value(
    //                       value: context.read<ExploreBloc>(),
    //                       child: const ExplorePage(),
    //                     ),
    //                     MultiBlocProvider(
    //                       providers: [
    //                         BlocProvider(
    //                           create: (context) => PoolBloc(
    //                             poolRepository: context.read<PoolRepository>(),
    //                             postRepository:
    //                                 context.read<DanbooruPostRepository>(),
    //                           )..add(const PoolRefreshed(
    //                               category: PoolCategory.series,
    //                               order: PoolOrder.latest,
    //                             )),
    //                         ),
    //                       ],
    //                       child: const PoolPage(),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  void _onMenuTap() {
    {
      expanded.value = !expanded.value;
    }
  }
}

class _NetworkUnavailableIndicator extends StatelessWidget {
  const _NetworkUnavailableIndicator();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NetworkBloc>().state;

    return ConditionalRenderWidget(
      condition:
          state is NetworkDisconnectedState || state is NetworkInitialState,
      childBuilder: (_) => const NetworkUnavailableIndicator(),
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
