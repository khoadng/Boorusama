// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/ui/home/latest_posts_view.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/ui/network_indicator_with_network_bloc.dart';
import 'package:boorusama/core/ui/widgets/animated_indexed_stack.dart';
import 'bottom_bar_widget.dart';
import 'other_features_page.dart';

class DanbooruHomePage extends StatefulWidget {
  const DanbooruHomePage({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  State<DanbooruHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<DanbooruHomePage> {
  final viewIndex = ValueNotifier(0);
  final selectedTag = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

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
            const NetworkUnavailableIndicatorWithNetworkBloc(),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: viewIndex,
                builder: (context, index, _) => AnimatedIndexedStack(
                  index: index,
                  children: [
                    RepositoryProvider(
                      create: (context) => DanbooruPostCubit.of(
                        context,
                        extra: DanbooruPostExtra(tag: () => selectedTag.value),
                      ),
                      child: _LatestView(
                        onMenuTap: widget.onMenuTap,
                        onSelectedTagChanged: (tag) => selectedTag.value = tag,
                      ),
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

class _ExplorePage extends StatelessWidget {
  const _ExplorePage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NetworkBloc>().state;

    return ExplorePage(
      useAppBarPadding: state is NetworkConnectedState,
    );
  }
}

class _LatestView extends StatelessWidget {
  const _LatestView({
    required this.onMenuTap,
    required this.onSelectedTagChanged,
  });

  final void Function()? onMenuTap;
  final void Function(String tag) onSelectedTagChanged;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NetworkBloc>().state;

    return LatestView(
      onSelectedTagChanged: onSelectedTagChanged,
      onMenuTap: onMenuTap,
      useAppBarPadding: state is NetworkConnectedState,
    );
  }
}
