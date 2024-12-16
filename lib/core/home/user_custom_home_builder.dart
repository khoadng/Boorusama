// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../boorus/engine/providers.dart';
import '../configs/ref.dart';
import '../configs/routes.dart';
import '../info/app_info.dart';
import 'home_page_controller.dart';

// Project imports:


class UserCustomHomeBuilder extends ConsumerWidget {
  const UserCustomHomeBuilder({
    super.key,
    required this.defaultView,
    required this.homePageController,
  });

  final Widget defaultView;
  final HomePageController homePageController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewKey = ref.watchLayoutConfigs?.home;
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final data = booruBuilder?.customHomeViewBuilders;

    if (data == null) return defaultView;

    final viewBuilder = data[viewKey]?.builder;

    if (viewKey == null || booruBuilder == null || viewBuilder == null) {
      return defaultView;
    }

    final view = viewBuilder(context, booruBuilder);

    return CustomHomeContainer(
      homePageController: homePageController,
      child: view,
    );
  }
}

class CustomHomeContainer extends ConsumerWidget {
  const CustomHomeContainer({
    super.key,
    required this.homePageController,
    required this.child,
  });

  final HomePageController homePageController;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    final appName = appInfo.appName;
    final config = ref.watchConfig;

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
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => goToUpdateBooruConfigPage(
                      context,
                      config: config,
                      initialTab: 'appearance',
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      child: const Icon(
                        Symbols.settings,
                        size: 18,
                        fill: 1,
                      ),
                    ),
                  ),
                ],
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
