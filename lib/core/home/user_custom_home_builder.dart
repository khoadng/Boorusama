// Flutter imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/bookmarks/widgets/bookmark_page.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'home.dart';

class UserCustomHomeBuilder extends ConsumerWidget {
  const UserCustomHomeBuilder({
    super.key,
    required this.defaultView,
    this.builder,
    required this.homePageController,
  });

  final Widget defaultView;
  final Widget? Function(BuildContext context, String viewName)? builder;
  final HomePageController homePageController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //FIXME: use the value from the config instead
    final viewName = ref.watch(selectedHomeViewProvider) ?? '';

    final view = builder?.call(
      context,
      viewName,
    );

    if (view == null) {
      return FallbackHomeBuilder(
        defaultView: defaultView,
        homePageController: homePageController,
      );
    }

    return CustomHomeContainer(
      homePageController: homePageController,
      canSearch: viewName == 'search',
      child: view,
    );
  }
}

class FallbackHomeBuilder extends ConsumerWidget {
  const FallbackHomeBuilder({
    super.key,
    required this.defaultView,
    required this.homePageController,
  });

  final Widget defaultView;
  final HomePageController homePageController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //FIXME: use the value from the config instead
    final viewName = ref.watch(selectedHomeViewProvider) ?? '';
    final searchPageBuilder =
        ref.watch(booruBuilderProvider)?.searchPageBuilder;

    final view = switch (viewName) {
      'bookmark' => const BookmarkPage(),
      'search' =>
        searchPageBuilder != null ? searchPageBuilder(context, null) : null,
      _ => null,
    };

    if (view == null) return defaultView;

    return CustomHomeContainer(
      homePageController: homePageController,
      canSearch: viewName == 'search',
      child: view,
    );
  }
}

class CustomHomeContainer extends ConsumerWidget {
  const CustomHomeContainer({
    super.key,
    required this.homePageController,
    required this.child,
    required this.canSearch,
  });

  final bool canSearch;
  final HomePageController homePageController;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    final appName = appInfo.appName;

    return Column(
      children: [
        AppBar(
          toolbarHeight: 40,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    splashRadius: 16,
                    icon: const Icon(Symbols.menu),
                    onPressed: () {
                      homePageController.openMenu();
                    },
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 18,
                    height: 18,
                    isAntiAlias: true,
                    filterQuality: FilterQuality.none,
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      appName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurface,
                        fontSize: 18,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ],
              ),
              if (!canSearch)
                CircularIconButton(
                  onPressed: () {
                    goToSearchPage(context);
                  },
                  icon: Icon(Symbols.search),
                ),
            ],
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
