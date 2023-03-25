// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_image_source_composer.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/danbooru_home_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/danbooru_home_page_desktop.dart';
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_bloc.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_home_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/side_bar_menu.dart';

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
          if (booru == null) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("You haven't add any booru yet"),
                      ElevatedButton.icon(
                        onPressed: () => goToManageBooruPage(context),
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
                builder: (context) => CustomContextMenuOverlay(
                  child: isMobilePlatform()
                      ? DanbooruHomePage(
                          onMenuTap: _onMenuTap,
                          key: ValueKey(booru.booruType),
                        )
                      : const DanbooruHomePageDesktop(),
                ),
              );
            case BooruType.gelbooru:
              return GelbooruProvider.create(
                context,
                booru: booru,
                builder: (gcontext) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => GelbooruPostBloc(
                        postRepository: gcontext.read<PostRepository>(),
                      )..add(const GelbooruPostBlocRefreshed(
                          tag: 'rating:general',
                        )),
                    ),
                  ],
                  child: CustomContextMenuOverlay(
                    child: GelbooruHomePage(
                      onMenuTap: _onMenuTap,
                    ),
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
