// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/home/side_bar_menu.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'home_page_controller.dart';

class EmptyBooruConfigHomePage extends ConsumerStatefulWidget {
  const EmptyBooruConfigHomePage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EmptyBooruConfigHomePageState();
}

class _EmptyBooruConfigHomePageState
    extends ConsumerState<EmptyBooruConfigHomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final homeController = HomePageController(
    scaffoldKey: scaffoldKey,
  );

  @override
  void dispose() {
    homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness: context.brightness,
        statusBarIconBrightness: context.onBrightness,
      ),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: InheritedHomePageController(
          controller: homeController,
          child: SideBarMenu(
            width: 300,
            padding: EdgeInsets.zero,
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No profiles available',
                      style: context.textTheme.titleLarge,
                    ),
                    Text(
                      'Add a profile to continue',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/boorus/add'),
                      child: const Text('Add Profile'),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
