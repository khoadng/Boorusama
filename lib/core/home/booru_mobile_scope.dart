// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme.dart';

class BooruMobileScope extends ConsumerWidget {
  const BooruMobileScope({
    super.key,
    required this.controller,
    required this.config,
    required this.menuBuilder,
    required this.home,
  });

  final HomePageController controller;
  final BooruConfig config;
  final Widget home;
  final List<Widget> Function(
      BuildContext context, HomePageController controller) menuBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only used to force rebuild when language changes
    ref.watch(settingsProvider.select((value) => value.language));
    final booruConfigSelectorPosition = ref.watch(
        settingsProvider.select((value) => value.booruConfigSelectorPosition));
    final swipeArea = ref.watch(settingsProvider
        .select((value) => value.swipeAreaToOpenSidebarPercentage));
    final hideLabel = ref
        .watch(settingsProvider.select((value) => value.hideBooruConfigLabel));

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness:
            context.themeMode.isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            context.themeMode.isLight ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawerEdgeDragWidth: _calculateDrawerEdgeDragWidth(context, swipeArea),
        key: controller.scaffoldKey,
        bottomNavigationBar:
            booruConfigSelectorPosition == BooruConfigSelectorPosition.bottom
                ? Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom,
                    ),
                    height: kBottomNavigationBarHeight - (hideLabel ? 4 : -8),
                    child: const BooruSelector(
                      direction: Axis.horizontal,
                    ),
                  )
                : null,
        drawer: SideBarMenu(
          width: 300,
          popOnSelect: true,
          padding: EdgeInsets.zero,
          initialContentBuilder: (context) => menuBuilder(context, controller),
        ),
        body: Column(
          children: [
            const NetworkUnavailableIndicatorWithState(),
            Expanded(
              child: home,
            ),
          ],
        ),
      ),
    );
  }
}

double _calculateDrawerEdgeDragWidth(BuildContext context, int areaPercentage) {
  final minValue = 20 + MediaQuery.paddingOf(context).left;
  final screenWidth = context.screenWidth;
  final value = (areaPercentage / 100).clamp(0.05, 1);
  final width = screenWidth * value;

  // if the width is less than the minimum value, return the minimum value
  return width < minValue ? minValue : width;
}
