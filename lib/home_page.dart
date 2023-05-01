// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_image_source_composer.dart';
import 'package:boorusama/boorus/danbooru/ui/home/danbooru_home_page.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/home/gelbooru_home_page.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/ui/home.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/home/side_bar_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const SideBarMenu(
        width: 300,
        popOnSelect: true,
        padding: EdgeInsets.zero,
      ),
      body: BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
        builder: (context, state) {
          final booru = state.booru;
          final config = state.booruConfig;

          if (booru == null) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("You haven't add any booru yet"),
                      ElevatedButton.icon(
                        onPressed: () => goToAddBooruPage(
                          context,
                          setCurrentBooruOnSubmit: true,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          switch (booru.booruType) {
            case BooruType.unknown:
              return const Center(
                child: Text('Unknown booru'),
              );
            case BooruType.aibooru:
            case BooruType.danbooru:
            case BooruType.safebooru:
            case BooruType.testbooru:
              return DanbooruProvider.create(
                context,
                booru: booru,
                sourceComposer: DanbooruImageSourceComposer(booru),
                builder: (context) {
                  return CustomContextMenuOverlay(
                    child: DanbooruHomePage(
                      onMenuTap: _onMenuTap,
                      key: ValueKey(config?.id),
                    ),
                  );
                },
              );
            case BooruType.gelbooru:
              final gkey = ValueKey(config?.id);

              return GelbooruProvider.create(
                context,
                key: gkey,
                booru: booru,
                builder: (gcontext) => CustomContextMenuOverlay(
                  child: GelbooruHomePage(
                    key: gkey,
                    onMenuTap: _onMenuTap,
                  ),
                ),
              );
            case BooruType.konachan:
            case BooruType.yandere:
            case BooruType.sakugabooru:
              final gkey = ValueKey(config?.id);

              return MoebooruProvider.create(
                context,
                key: gkey,
                booru: booru,
                builder: (gcontext) => CustomContextMenuOverlay(
                  child: MoebooruHomePage(
                    key: gkey,
                    onMenuTap: _onMenuTap,
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  void _onMenuTap() {
    scaffoldKey.currentState!.openDrawer();
  }
}
