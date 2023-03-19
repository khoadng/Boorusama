// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_image_source_composer.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/side_bar.dart';
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_bloc.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_home_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/domain/posts/post_repository.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'danbooru_home_page.dart';

class HomePage2 extends StatelessWidget {
  const HomePage2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                builder: (context) => const CustomContextMenuOverlay(
                  child: DanbooruHomePage(),
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
                          tag: 'belko',
                        )),
                    ),
                  ],
                  child: const CustomContextMenuOverlay(
                    child: GelbooruHomePage(),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
