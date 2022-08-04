// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'post_action_toolbar.dart';
import 'recommend_section.dart';

class RecommendArtistList extends StatelessWidget {
  const RecommendArtistList({
    Key? key,
    required this.post,
    this.header,
    this.useSeperator = false,
  }) : super(key: key);

  final Post post;
  final Widget Function(Recommended item)? header;
  final bool useSeperator;

  @override
  Widget build(BuildContext context) {
    if (post.artistTags.isEmpty) return const SizedBox.shrink();
    return BlocBuilder<RecommendedArtistPostCubit,
        AsyncLoadState<List<Recommended>>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final recommendedItems = state.data!;

          if (recommendedItems.isEmpty) return const SizedBox.shrink();

          return Column(children: [
            ...recommendedItems
                .map((item) => RecommendPostSection(
                      header: header?.call(item) ??
                          ListTile(
                            onTap: () => AppRouter.router.navigateTo(
                              context,
                              '/artist',
                              routeSettings: RouteSettings(
                                arguments: [
                                  item.tag,
                                  post.normalImageUrl,
                                ],
                              ),
                            ),
                            title: Text(item.title),
                            trailing:
                                const Icon(Icons.keyboard_arrow_right_rounded),
                          ),
                      posts: item.posts,
                    ))
                .toList(),
            if (useSeperator) const Divider(),
          ]);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class RecommendCharacterList extends StatelessWidget {
  const RecommendCharacterList({
    Key? key,
    required this.post,
    this.useSeperator = false,
  }) : super(key: key);

  final Post post;

  final bool useSeperator;

  @override
  Widget build(BuildContext context) {
    if (post.characterTags.isEmpty) return const SizedBox.shrink();
    return BlocBuilder<RecommendedCharacterPostCubit,
        AsyncLoadState<List<Recommended>>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final recommendedItems = state.data!;

          if (recommendedItems.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              ...recommendedItems
                  .map((item) => RecommendPostSection(
                        header: ListTile(
                          onTap: () => AppRouter.router.navigateTo(
                            context,
                            '/character',
                            routeSettings: RouteSettings(
                              arguments: [
                                item.tag,
                                post.normalImageUrl,
                              ],
                            ),
                          ),
                          title: Text(item.title),
                          trailing:
                              const Icon(Icons.keyboard_arrow_right_rounded),
                        ),
                        posts: item.posts,
                      ))
                  .toList(),
              if (useSeperator) const Divider(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class ActionBar extends StatelessWidget {
  const ActionBar({
    Key? key,
    required this.imagePath,
    required this.post,
  }) : super(key: key);

  final ValueNotifier<String?> imagePath;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: imagePath,
      builder: (context, value, child) => BlocProvider(
        create: (context) => PostVoteBloc(
          postVoteRepository: context.read<PostVoteRepository>(),
          score: post.score,
          upScore: post.upScore,
          downScore: post.downScore,
        ),
        child: PostActionToolbar(
          post: post,
          imagePath: value,
        ),
      ),
    );
  }
}
