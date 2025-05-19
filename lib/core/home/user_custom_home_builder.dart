// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../boorus/engine/providers.dart';
import '../configs/ref.dart';
import '../configs/routes.dart';
import '../foundation/networking.dart';
import '../info/app_info.dart';
import 'custom_home.dart';
import 'home_page_controller.dart';

class UserCustomHomeBuilder extends ConsumerWidget {
  const UserCustomHomeBuilder({
    required this.defaultView,
    super.key,
  });

  final Widget defaultView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewKey = ref.watch(customHomeViewKeyProvider);
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));
    final data = booruBuilder?.customHomeViewBuilders;

    if (data == null) return defaultView;

    final viewBuilder = data[viewKey]?.builder;

    if (viewKey == null || booruBuilder == null || viewBuilder == null) {
      return defaultView;
    }

    final view = viewBuilder(context, booruBuilder);

    return CustomHomeContainer(
      child: view,
    );
  }
}

class CustomHomeContainer extends StatelessWidget {
  const CustomHomeContainer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer(
          builder: (_, ref, __) {
            final state = ref.watch(networkStateProvider);

            return SafeArea(
              bottom: false,
              left: false,
              right: false,
              top: state is! NetworkDisconnectedState,
              child: const _AppBar(),
            );
          },
        ),
        Expanded(
          // Using MediaQuery.removePadding is fine here cause the child is expected to be a const widget so it won't be rebuilt
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

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final controller = InheritedHomePageController.of(context);

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                splashRadius: 16,
                icon: const Icon(Symbols.menu),
                onPressed: () {
                  controller.openMenu();
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
                child: Consumer(
                  builder: (_, ref, __) {
                    final appInfo = ref.watch(appInfoProvider);
                    final appName = appInfo.appName;

                    return Text(
                      appName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        letterSpacing: -1,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              Consumer(
                builder: (_, ref, __) {
                  final config = ref.watchConfig;

                  return InkWell(
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
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
