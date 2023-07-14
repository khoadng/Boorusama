// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/pages/home/latest_posts_view.dart';
import 'package:boorusama/boorus/home_page_scope.dart';
import 'package:boorusama/foundation/networking/network_provider.dart';
import 'package:boorusama/foundation/networking/network_state.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'other_features_page.dart';

class DanbooruHomePage extends ConsumerWidget {
  const DanbooruHomePage({
    super.key,
    required this.controller,
    required this.bottomBar,
  });

  final HomePageController controller;
  final Widget bottomBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            context.themeMode.isLight ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const NetworkUnavailableIndicatorWithState(),
            Expanded(
                child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) => AnimatedIndexedStack(
                index: value,
                children: [
                  _LatestView(
                    onMenuTap: controller.openMenu,
                  ),
                  const _ExplorePage(),
                  const OtherFeaturesPage(),
                ],
              ),
            )),
          ],
        ),
        bottomNavigationBar: bottomBar,
      ),
    );
  }
}

class _ExplorePage extends ConsumerWidget {
  const _ExplorePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(networkStateProvider);

    return ExplorePage(
      useAppBarPadding: state is NetworkConnectedState,
    );
  }
}

class _LatestView extends ConsumerWidget {
  const _LatestView({
    required this.onMenuTap,
  });

  final void Function()? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(networkStateProvider);

    return LatestView(
      onMenuTap: onMenuTap,
      useAppBarPadding: state is NetworkConnectedState,
    );
  }
}
