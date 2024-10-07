// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'anime_pictures_top_page.dart';

class AnimePicturesHomePage extends ConsumerStatefulWidget {
  const AnimePicturesHomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<AnimePicturesHomePage> createState() =>
      _AnimePicturesHomePageState();
}

class _AnimePicturesHomePageState extends ConsumerState<AnimePicturesHomePage> {
  @override
  Widget build(BuildContext context) {
    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(
            Symbols.explore,
            fill: 1,
          ),
          title: const Text('Top'),
          onTap: () => context.navigator.push(
            CupertinoPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Top'),
                ),
                body: const CustomContextMenuOverlay(
                  child: AnimePicturesTopPage(),
                ),
              ),
            ),
          ),
        ),
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'Top',
        ),
      ],
      desktopViews: const [
        AnimePicturesTopPage(),
      ],
    );
  }
}
