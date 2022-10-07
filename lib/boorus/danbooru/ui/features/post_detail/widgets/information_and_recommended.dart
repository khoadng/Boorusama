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
import 'package:boorusama/core/core.dart';
import 'post_action_toolbar.dart';
import 'recommend_section.dart';

class RecommendArtistList extends StatefulWidget {
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
  State<RecommendArtistList> createState() => _RecommendArtistListState();
}

class _RecommendArtistListState extends State<RecommendArtistList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.post.artistTags.isEmpty) return const SizedBox.shrink();
    final screenSize = Screen.of(context).size;

    return BlocProvider(
      create: (context) => RecommendedArtistPostCubit(
        postRepository: context.read<IPostRepository>(),
      )..add(
          RecommendedPostRequested(
            amount: screenSize == ScreenSize.large ? 9 : 6,
            currentPostId: widget.post.id,
            tags: widget.post.artistTags,
          ),
        ),
      child: Builder(builder: (context) {
        return BlocBuilder<RecommendedArtistPostCubit,
            AsyncLoadState<List<Recommended>>>(
          builder: (context, state) {
            if (state.status == LoadStatus.success) {
              final recommendedItems = state.data!;

              if (recommendedItems.isEmpty) return const SizedBox.shrink();

              return Column(children: [
                ...recommendedItems
                    .map((item) => RecommendPostSection(
                          header: widget.header?.call(item) ??
                              ListTile(
                                onTap: () => AppRouter.router.navigateTo(
                                  context,
                                  '/artist',
                                  routeSettings: RouteSettings(
                                    arguments: [
                                      item.tag,
                                      widget.post.normalImageUrl,
                                    ],
                                  ),
                                ),
                                title: Text(item.title),
                                trailing: const Icon(
                                    Icons.keyboard_arrow_right_rounded),
                              ),
                          posts: item.posts,
                        ))
                    .toList(),
                if (widget.useSeperator) const Divider(),
              ]);
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RecommendCharacterList extends StatefulWidget {
  const RecommendCharacterList({
    Key? key,
    required this.post,
    this.useSeperator = false,
  }) : super(key: key);

  final Post post;
  final bool useSeperator;

  @override
  State<RecommendCharacterList> createState() => _RecommendCharacterListState();
}

class _RecommendCharacterListState extends State<RecommendCharacterList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.post.characterTags.isEmpty) return const SizedBox.shrink();
    final screenSize = Screen.of(context).size;
    return BlocProvider(
      create: (context) => RecommendedCharacterPostCubit(
          postRepository: context.read<IPostRepository>())
        ..add(RecommendedPostRequested(
          amount: screenSize == ScreenSize.large ? 9 : 6,
          currentPostId: widget.post.id,
          tags: widget.post.characterTags.take(3).toList(),
        )),
      child: Builder(builder: (context) {
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
                                    widget.post.normalImageUrl,
                                  ],
                                ),
                              ),
                              title: Text(item.title),
                              trailing: const Icon(
                                  Icons.keyboard_arrow_right_rounded),
                            ),
                            posts: item.posts,
                          ))
                      .toList(),
                  if (widget.useSeperator) const Divider(),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
