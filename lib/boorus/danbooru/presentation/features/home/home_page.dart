// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/networking/network_bloc.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/pool/pool_page.dart';
import 'package:boorusama/core/presentation/widgets/animated_indexed_stack.dart';
import 'bottom_bar_widget.dart';
import 'explore/explore_page.dart';
import 'latest/latest_posts_view.dart';
import 'side_bar.dart';

class HomePage extends HookWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bottomTabIndex = useState(0);

    useEffect(() {
      Future.microtask(
          () => ReadContext(context).read<AuthenticationCubit>().logIn());
      return () => {};
    }, []);

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            BlocBuilder<NetworkBloc, NetworkState>(
              builder: (context, state) {
                if (state is NetworkConnectedState) {
                  return SizedBox.shrink();
                } else if (state is NetworkDisconnectedState) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.black,
                      child: Text("Network unavailable"),
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
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
                        onMenuTap: () => scaffoldKey.currentState!.openDrawer(),
                      ),
                      ExplorePage(),
                      PoolPage(),
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
