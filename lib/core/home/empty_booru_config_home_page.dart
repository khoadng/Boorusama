// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../configs/create/routes.dart';
import '../theme.dart';
import 'home_page_controller.dart';
import 'side_bar_menu.dart';

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
        statusBarBrightness: Theme.of(context).brightness,
        statusBarIconBrightness: context.onBrightness,
      ),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: InheritedHomePageController(
          controller: homeController,
          child: const SideBarMenu(
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
                      'No profiles available'.hc,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Add a profile to continue'.hc,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => goToAddBooruConfigPage(ref),
                      child: Text('Add Profile'.hc),
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
