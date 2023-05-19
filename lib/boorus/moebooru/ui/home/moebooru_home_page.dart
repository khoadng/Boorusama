// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/boorus/moebooru/ui/home/moebooru_bottom_bar.dart';
import 'package:boorusama/boorus/moebooru/ui/popular/moebooru_popular_page.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/network_indicator_with_state.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/widgets/animated_indexed_stack.dart';

class MoebooruHomePage extends ConsumerStatefulWidget {
  const MoebooruHomePage({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  ConsumerState<MoebooruHomePage> createState() => _MoebooruHomePageState();
}

class _MoebooruHomePageState extends ConsumerState<MoebooruHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final viewIndex = ValueNotifier(0);

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
        body: Column(
          children: [
            const NetworkUnavailableIndicatorWithState(),
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
                            title: BooruSearchBar(
                              enabled: false,
                              leading: widget.onMenuTap != null
                                  ? IconButton(
                                      icon: const Icon(Icons.menu),
                                      onPressed: () => widget.onMenuTap?.call(),
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
  }
}
