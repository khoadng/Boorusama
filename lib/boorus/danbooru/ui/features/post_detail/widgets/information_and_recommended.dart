// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/fetchers/recommend_post_fetcher.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
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
  final Widget Function(String item)? header;
  final bool useSeperator;

  @override
  Widget build(BuildContext context) {
    if (post.artistTags.isEmpty) return const SizedBox.shrink();
    final screenSize = Screen.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...post.artistTags.map(
          (tag) => BlocProvider(
            create: (context) => PostBloc.of(context)
              ..add(PostRefreshed(
                  fetcher: RecommendPostFetcher(
                tag: tag,
                postId: post.id,
                amount: screenSize == ScreenSize.large ? 9 : 6,
              ))),
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state.status == LoadStatus.success) {
                  return RecommendPostSection(
                    header: header?.call(tag) ??
                        ListTile(
                          onTap: () => AppRouter.router.navigateTo(
                            context,
                            '/artist',
                            routeSettings: RouteSettings(
                              arguments: [
                                tag,
                                post.normalImageUrl,
                              ],
                            ),
                          ),
                          title: Text(tag.removeUnderscoreWithSpace()),
                          trailing:
                              const Icon(Icons.keyboard_arrow_right_rounded),
                        ),
                    posts: state.posts,
                    onTap: (index) => goToDetailPage(
                      context: context,
                      posts: state.posts,
                      initialIndex: index,
                      postBloc: context.read<PostBloc>(),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ],
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
    final screenSize = Screen.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...post.characterTags.map(
          (tag) => BlocProvider(
            create: (context) => PostBloc.of(context)
              ..add(PostRefreshed(
                  fetcher: RecommendPostFetcher(
                tag: tag,
                postId: post.id,
                amount: screenSize == ScreenSize.large ? 9 : 6,
              ))),
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state.status == LoadStatus.success) {
                  return RecommendPostSection(
                    header: ListTile(
                      onTap: () => AppRouter.router.navigateTo(
                        context,
                        '/character',
                        routeSettings: RouteSettings(
                          arguments: [
                            tag,
                            post.normalImageUrl,
                          ],
                        ),
                      ),
                      title: Text(tag.removeUnderscoreWithSpace()),
                      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    ),
                    posts: state.posts,
                    onTap: (index) => goToDetailPage(
                      context: context,
                      posts: state.posts,
                      initialIndex: index,
                      postBloc: context.read<PostBloc>(),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ActionBar extends StatelessWidget {
  const ActionBar({
    Key? key,
    required this.imagePath,
    required this.postData,
  }) : super(key: key);

  final ValueNotifier<String?> imagePath;
  final PostData postData;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: imagePath,
      builder: (context, value, child) => PostActionToolbar(
        postData: postData,
        imagePath: value,
      ),
    );
  }
}
