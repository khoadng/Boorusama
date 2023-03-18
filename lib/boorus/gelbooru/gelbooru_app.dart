// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/main.dart';
import 'application/gelbooru_post_bloc.dart';
import 'infra/gelbooru_post_repository_api.dart';
import 'ui/gelbooru_home_page.dart';

class GelbooruApp extends StatelessWidget {
  const GelbooruApp({
    super.key,
    required this.booru,
  });

  final Booru booru;

  @override
  Widget build(BuildContext context) {
    final dio = context.read<DioProvider>().getDio(booru.url);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GelbooruPostBloc(
            postRepository: GelbooruPostRepositoryApi(
              api: GelbooruApi(dio),
            ),
          )..add(const GelbooruPostBlocRefreshed(
              tag: 'rating:general',
            )),
        ),
      ],
      child: const GelbooruHomePage(),
    );
  }
}
