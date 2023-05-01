// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/boorus/moebooru/ui/home/moebooru_bottom_bar.dart';
import 'package:boorusama/boorus/moebooru/ui/popular/moebooru_popular_page.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/core/application/theme/theme_bloc.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/network_indicator_with_network_bloc.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';
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

class _MoebooruHomePageState extends State<MoebooruHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
                        PostScope(
                          fetcher: (page) => context
                              .read<PostRepository>()
                              .getPostsFromTags('', page),
                          builder: (context, controller, errors) =>
                              MoebooruInfinitePostList(
                            errors: errors,
                            controller: controller,
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
                                  onTap: () => goToMoebooruSearchPage(context),
                                ),
                                floating: true,
                                snap: true,
                                automaticallyImplyLeading: false,
                              ),
                            ],
                          ),
                        ),
                        const MoebooruPopularPage()
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
