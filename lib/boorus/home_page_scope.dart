// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/home/side_bar_menu.dart';
import 'package:boorusama/boorus/core/widgets/custom_context_menu_overlay.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/widgets/conditional_parent_widget.dart';

class HomePageScope extends StatefulWidget {
  const HomePageScope({
    super.key,
    required this.builder,
    this.bottomBar,
  });

  final Widget Function(
    BuildContext context,
    HomePageController controller,
  )? bottomBar;

  final Widget Function(
    BuildContext context,
    Widget bottomBar,
    HomePageController controller,
  ) builder;

  @override
  State<HomePageScope> createState() => _HomePageScopeState();
}

class _HomePageScopeState extends State<HomePageScope> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final homePageController = HomePageController(scaffoldKey: scaffoldKey);

  @override
  void dispose() {
    homePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: isMobilePlatform()
          ? const SideBarMenu(
              width: 300,
              popOnSelect: true,
              padding: EdgeInsets.zero,
            )
          : null,
      body: ConditionalParentWidget(
        condition: !isMobilePlatform(),
        conditionalBuilder: (child) => Row(
          children: [
            SideBarMenu(
              width: 300,
              popOnSelect: false,
              padding: EdgeInsets.zero,
              initialContentBuilder: (context) => [
                if (widget.bottomBar != null)
                  widget.bottomBar!(context, homePageController),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(child: child),
          ],
        ),
        child: CustomContextMenuOverlay(
          child: widget.builder(
            context,
            isMobilePlatform() && widget.bottomBar != null
                ? widget.bottomBar!(context, homePageController)
                : const SizedBox.shrink(),
            homePageController,
          ),
        ),
      ),
    );
  }
}

class HomePageController extends ValueNotifier<int> {
  HomePageController({
    required this.scaffoldKey,
  }) : super(0);

  final GlobalKey<ScaffoldState> scaffoldKey;

  void goToTab(int index) {
    value = index;
  }

  void openMenu() {
    scaffoldKey.currentState!.openDrawer();
  }
}
