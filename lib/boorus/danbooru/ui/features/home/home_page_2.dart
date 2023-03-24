// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_image_source_composer.dart';
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_bloc.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_home_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/side_bar_menu.dart';
import 'danbooru_home_page.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({
    super.key,
  });

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
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
            return const Center(
              child: Text('You havent set any booru yet'),
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
                  child: DanbooruHomePage(
                    onMenuTap: _onMenuTap,
                    key: ValueKey(booru.booruType),
                  ),
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
