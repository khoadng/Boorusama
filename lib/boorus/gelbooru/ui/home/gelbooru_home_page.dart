// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'package:boorusama/core/ui/widgets/network_unavailable_indicator.dart';

class GelbooruHomePage extends StatefulWidget {
  const GelbooruHomePage({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  State<GelbooruHomePage> createState() => _GelbooruHomePageState();
}

class _GelbooruHomePageState extends State<GelbooruHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
            body: Row(
              children: [
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
                        child: PostScope(
                          fetcher: (page) => context
                              .read<PostRepository>()
                              .getPostsFromTags('', page),
                          builder: (context, controller, errors) =>
                              GelbooruInfinitePostList(
                            errors: errors,
                            controller: controller,
                            sliverHeaderBuilder: (context) => [
                              SliverAppBar(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                toolbarHeight: kToolbarHeight * 1.2,
                                title: BooruSearchBar(
                                  enabled: false,
                                  leading: widget.onMenuTap != null
                                      ? IconButton(
                                          icon: const Icon(Icons.menu),
                                          onPressed: () =>
                                              widget.onMenuTap?.call(),
                                        )
                                      : null,
                                  onTap: () => goToGelbooruSearchPage(context),
                                ),
                                floating: true,
                                snap: true,
                                automaticallyImplyLeading: false,
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
        );
      },
    );
  }
}
