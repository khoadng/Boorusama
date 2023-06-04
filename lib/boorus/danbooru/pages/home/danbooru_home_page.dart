// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pages/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/pages/home/latest_posts_view.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/network_indicator_with_state.dart';
import 'package:boorusama/core/ui/widgets/animated_indexed_stack.dart';
import 'bottom_bar_widget.dart';
import 'other_features_page.dart';

class DanbooruHomePage extends ConsumerStatefulWidget {
  const DanbooruHomePage({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  ConsumerState<DanbooruHomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<DanbooruHomePage> {
  final viewIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            theme == ThemeMode.light ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const NetworkUnavailableIndicatorWithState(),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: viewIndex,
                builder: (context, index, _) => AnimatedIndexedStack(
                  index: index,
                  children: [
                    _LatestView(
                      onMenuTap: widget.onMenuTap,
                    ),
                    const _ExplorePage(),
                    const OtherFeaturesPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomBar(
          initialValue: viewIndex.value,
          onTabChanged: (value) => viewIndex.value = value,
        ),
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
