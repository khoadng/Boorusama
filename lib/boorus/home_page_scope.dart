// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/home/side_bar_menu.dart';
import 'package:boorusama/boorus/core/pages/home/switch_booru_modal.dart';
import 'package:boorusama/boorus/core/widgets/custom_context_menu_overlay.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/conditional_parent_widget.dart';
import 'package:boorusama/widgets/split.dart';

@Deprecated('each booru should have its own home page scope')
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
      backgroundColor: context.theme.cardColor,
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
        conditionalBuilder: (child) => Split(
          initialFractions: const [0.2, 0.8],
          axis: Axis.horizontal,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  CurrentBooruTile(
                    onTap: () {
                      showMaterialModalBottomSheet(
                        context: context,
                        duration: const Duration(milliseconds: 250),
                        animationCurve: Curves.easeOut,
                        builder: (context) => const SwitchBooruModal(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  if (widget.bottomBar != null)
                    widget.bottomBar!(context, homePageController),
                  const Divider(),
                  if (widget.menuBuilder != null) ...[
                    ...widget.menuBuilder!(context),
                  ],
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
