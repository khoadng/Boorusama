import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/danbooru_home_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/side_bar.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'safebooru_home_page.dart';

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
              return const DanbooruHomePage();
            case BooruType.safebooru:
            case BooruType.testbooru:
              return const SafebooruHomePage();
          }
        },
      ),
    );
  }
}
