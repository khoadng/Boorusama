// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/core/infrastructure/networking/network_info.dart';
import 'package:boorusama/core/presentation/widgets/animated_indexed_stack.dart';
import 'bottom_bar_widget.dart';
import 'explore/explore_page.dart';
import 'latest/latest_posts_view.dart';
import 'side_bar.dart';

class HomePage extends HookWidget {
  HomePage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bottomTabIndex = useState(0);

    final networkStatus = useProvider(networkStatusProvider);

    useEffect(() {
      Future.microtask(() => context.read(authenticationStateNotifierProvider).logIn());
      return () => {};
    }, []);

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            networkStatus.when(
              data: (value) => value.when(
                unknown: () => SizedBox.shrink(),
                available: () => SizedBox.shrink(),
                unavailable: () => Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.black,
                    child: Text("Network unavailable"),
                  ),
                ),
              ),
              loading: () => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Theme.of(context).appBarTheme.color,
                  child: Text("Connecting"),
                ),
              ),
              error: (error, stackTrace) => Material(
                color: Theme.of(context).appBarTheme.color,
                child: Padding(padding: EdgeInsets.only(bottom: 10), child: Text("Something went wrong")),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Scaffold(
                  extendBody: true,
                  key: scaffoldKey,
                  drawer: SideBarMenu(),
                  resizeToAvoidBottomInset: false,
                  body: AnimatedIndexedStack(
                    index: bottomTabIndex.value,
                    children: <Widget>[
                      LatestView(
                        onMenuTap: () => scaffoldKey.currentState.openDrawer(),
                      ),
                      ExplorePage(),
                    ],
                  ),
                  bottomNavigationBar: BottomBar(
                    onTabChanged: (value) => bottomTabIndex.value = value,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
