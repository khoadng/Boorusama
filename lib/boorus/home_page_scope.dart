// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/home/side_bar_menu.dart';
import 'package:boorusama/boorus/core/widgets/custom_context_menu_overlay.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/widgets/conditional_parent_widget.dart';
import 'package:boorusama/widgets/split.dart';

class HomePageScope extends StatefulWidget {
  const HomePageScope({
    super.key,
    required this.builder,
    this.menuBuilder,
    this.bottomBar,
  });

  final Widget Function(
    BuildContext context,
    HomePageController controller,
  )? bottomBar;

  final List<Widget> Function(BuildContext context)? menuBuilder;

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
              popOnSelect: true,
              padding: EdgeInsets.zero,
            )
          : null,
      body: ConditionalParentWidget(
        condition: !isMobilePlatform(),
        conditionalBuilder: (child) => Split(
          initialFractions: const [0.25, 0.75],
          axis: Axis.horizontal,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const CurrentBooruTile(),
                  if (widget.bottomBar != null)
                    widget.bottomBar!(context, homePageController),
                ],
              ),
            ),
            child,
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
