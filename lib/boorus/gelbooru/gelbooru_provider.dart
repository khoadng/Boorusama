// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_repository.dart';
import 'package:boorusama/core/domain/posts/post_repository.dart';
import 'package:boorusama/main.dart';
import 'infra/gelbooru_post_repository_api.dart';
import 'infra/gelbooru_tag_repository_api.dart';

class GelbooruProvider extends StatelessWidget {
  const GelbooruProvider({
    super.key,
    required this.postRepository,
    required this.tagRepository,
    required this.builder,
  });

  factory GelbooruProvider.create(
    BuildContext context, {
    required Booru booru,
    required Widget Function(BuildContext context) builder,
  }) {
    final dio = context.read<DioProvider>().getDio(booru.url);
    final api = GelbooruApi(dio);

    final postRepo = GelbooruPostRepositoryApi(
      api: api,
    );

    final tagRepo = GelbooruTagRepositoryApi(api);

    return GelbooruProvider(
      postRepository: postRepo,
      tagRepository: tagRepo,
      builder: builder,
    );
  }

  final PostRepository postRepository;
  final TagRepository tagRepository;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: postRepository),
        RepositoryProvider.value(value: tagRepository),
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}
