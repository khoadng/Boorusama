// Flutter imports:
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/side_bar.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_app.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
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
            case BooruType.danbooru:
            case BooruType.safebooru:
            case BooruType.testbooru:
              return DanbooruProvider.create(
                context,
                booru: booru,
                builder: (context) => const CustomContextMenuOverlay(
                  child: DanbooruHomePage(),
                ),
              );
            case BooruType.gelbooru:
              return CustomContextMenuOverlay(
                child: GelbooruApp(booru: booru),
              );
          }
        },
      ),
    );
  }
}
