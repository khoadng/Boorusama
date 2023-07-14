// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/home_page_scope.dart';
import 'package:boorusama/boorus/moebooru/pages/popular/moebooru_popular_page.dart';
import 'package:boorusama/boorus/moebooru/pages/popular/moebooru_popular_recent_page.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class MoebooruHomePage extends ConsumerStatefulWidget {
  const MoebooruHomePage({
    super.key,
    required this.controller,
    required this.bottomBar,
  });

  final HomePageController controller;
  final Widget bottomBar;

  @override
  ConsumerState<MoebooruHomePage> createState() => _MoebooruHomePageState();
}

class _MoebooruHomePageState extends ConsumerState<MoebooruHomePage> {
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
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const NetworkUnavailableIndicatorWithState(),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: widget.controller,
                builder: (context, index, _) => AnimatedIndexedStack(
                  index: index,
                  children: [
                    PostScope(
                      fetcher: (page) =>
                          ref.read(postRepoProvider).getPostsFromTags('', page),
                      builder: (context, controller, errors) =>
                          MoebooruInfinitePostList(
                        errors: errors,
                        controller: controller,
                        sliverHeaderBuilder: (context) => [
                          SliverAppBar(
                            backgroundColor:
                                context.theme.scaffoldBackgroundColor,
                            toolbarHeight: kToolbarHeight * 1.2,
                            title: HomeSearchBar(
                              onMenuTap: widget.controller.openMenu,
                              onTap: () => goToMoebooruSearchPage(ref, context),
                            ),
                            floating: true,
                            snap: true,
                            automaticallyImplyLeading: false,
                          ),
                        ],
                      ),
                    ),
                    const MoebooruPopularPage(),
                    const MoebooruPopularRecentPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.bottomBar,
      ),
    );
  }
}
