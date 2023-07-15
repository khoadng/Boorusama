// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/widgets/home_search_bar.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/pages/home/danbooru_bottom_bar.dart';
import 'package:boorusama/boorus/danbooru/pages/home/danbooru_home_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/home_page_scope.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

class DanbooruScope extends StatefulWidget {
  const DanbooruScope({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  State<DanbooruScope> createState() => _DanbooruScopeState();
}

class _DanbooruScopeState extends State<DanbooruScope> {
  @override
  Widget build(BuildContext context) {
    return HomePageScope(
      bottomBar: (context, controller) => ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) => DanbooruBottomBar(
          initialValue: value,
          onTabChanged: (value) => controller.goToTab(value),
        ),
      ),
      builder: (context, tab, controller) => DanbooruProvider(
        builder: (context) {
          return DanbooruHomePage(
            key: ValueKey(widget.config.id),
            controller: controller,
            bottomBar: tab,
            toolbarBuilder: (context) => isMobilePlatform()
                ? SliverAppBar(
                    backgroundColor: context.theme.scaffoldBackgroundColor,
                    toolbarHeight: kToolbarHeight * 1.2,
                    primary: true,
                    title: HomeSearchBar(
                      onMenuTap: controller.openMenu,
                      onTap: () => goToSearchPage(context),
                    ),
                    floating: true,
                    snap: true,
                    automaticallyImplyLeading: false,
                  )
                : const SliverSizedBox.shrink(),
          );
        },
      ),
    );
  }
}
