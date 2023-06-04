// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/network_indicator_with_state.dart';
import 'package:boorusama/boorus/core/pages/posts/post_scope.dart';
import 'package:boorusama/boorus/core/pages/search_bar.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/gelbooru/feat/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';

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
                      fetcher: (page) => ref
                          .watch(gelbooruPostRepoProvider)
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
                                      splashRadius: 16,
                                      icon: const Icon(Icons.menu),
                                      onPressed: () => widget.onMenuTap?.call(),
                                    )
                                  : null,
                              onTap: () => goToGelbooruSearchPage(ref, context),
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
