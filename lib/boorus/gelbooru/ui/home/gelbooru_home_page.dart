// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/network_indicator_with_state.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class GelbooruHomePage extends ConsumerStatefulWidget {
  const GelbooruHomePage({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  ConsumerState<GelbooruHomePage> createState() => _GelbooruHomePageState();
}

class _GelbooruHomePageState extends ConsumerState<GelbooruHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            theme == ThemeMode.light ? Brightness.dark : Brightness.light,
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
                  const NetworkUnavailableIndicatorWithState(),
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
                                      onPressed: () => widget.onMenuTap?.call(),
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
  }
}
