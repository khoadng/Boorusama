// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_vote_info_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_level.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_repository.dart';
import 'package:boorusama/boorus/danbooru/ui/features/users/user_level_colors.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

class PostStatsTile extends StatelessWidget {
  const PostStatsTile({
    super.key,
    required this.post,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Post post;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        children: [
          _StatButton(
            enable: post.hasFavorite,
            onTap: () => showAdaptiveBottomSheet(
              context,
              builder: (context) => BlocProvider(
                create: (context) => PostFavoriteBloc(
                  favoritePostRepository:
                      context.read<FavoritePostRepository>(),
                  userRepository: context.read<UserRepository>(),
                )..add(PostFavoriteFetched(
                    postId: post.id,
                    refresh: true,
                  )),
                child: _FavoriterView(
                  post: post,
                ),
              ),
            ),
            child: RichText(
              text: TextSpan(
                text: '${post.favCount} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text: 'favorites.counter'.plural(post.favCount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _StatButton(
            enable: post.hasVoter,
            onTap: () => showAdaptiveBottomSheet(
              context,
              builder: (context) => BlocProvider(
                create: (context) => PostVoteInfoBloc(
                  postVoteRepository: context.read<PostVoteRepository>(),
                  userRepository: context.read<UserRepository>(),
                )..add(PostVoteInfoFetched(
                    postId: post.id,
                    refresh: true,
                  )),
                child: _VoterView(
                  post: post,
                ),
              ),
            ),
            child: RichText(
              text: TextSpan(
                text: '${post.score} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text:
                        '${'post.detail.score'.plural(post.score)} ${_generatePercentText(post)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _StatButton(
            enable: post.hasComment,
            child: RichText(
              text: TextSpan(
                text: '${post.totalComments} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text: 'comment.counter'.plural(post.totalComments),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({
    required this.child,
    required this.enable,
    this.onTap,
  });

  final Widget child;
  final bool enable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: enable,
      conditionalBuilder: (child) => InkWell(
        onTap: onTap,
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: child,
      ),
    );
  }
}

String _generatePercentText(Post post) {
  return post.totalVote > 0
      ? '(${(post.upvotePercent * 100).toInt()}% upvoted)'
      : '';
}

class _VoterView extends StatefulWidget {
  const _VoterView({
    required this.post,
  });

  final Post post;

  @override
  State<_VoterView> createState() => _VoterViewState();
}

class _VoterViewState extends State<_VoterView> {
  final scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (_isBottom) {
        context
            .read<PostVoteInfoBloc>()
            .add(PostVoteInfoFetched(postId: widget.post.id));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: BlocBuilder<PostVoteInfoBloc, PostVoteInfoState>(
        builder: (context, state) => state.refreshing
            ? const Center(child: CircularProgressIndicator.adaptive())
            : CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final voter = state.upvoters[index];

                        return _InfoTile(
                          title: voter.user.name,
                          level: voter.user.level,
                        );
                      },
                      childCount: state.upvoters.length,
                    ),
                  ),
                  if (state.loading)
                    const SliverToBoxAdapter(
                      child:
                          Center(child: CircularProgressIndicator.adaptive()),
                    ),
                ],
              ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.level,
  });

  final String title;
  final UserLevel level;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.comfortable,
      title: Text(
        title,
        style: TextStyle(color: Color(getUserHexColor(level))),
      ),
    );
  }
}

class _FavoriterView extends StatefulWidget {
  const _FavoriterView({
    required this.post,
  });

  final Post post;

  @override
  State<_FavoriterView> createState() => _FavoriterViewState();
}

class _FavoriterViewState extends State<_FavoriterView> {
  final scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (_isBottom) {
        context
            .read<PostFavoriteBloc>()
            .add(PostFavoriteFetched(postId: widget.post.id));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: BlocBuilder<PostFavoriteBloc, PostFavoriteState>(
        builder: (context, state) => state.refreshing
            ? const Center(child: CircularProgressIndicator.adaptive())
            : CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = state.favoriters[index];

                        return ListTile(
                          title: Text(
                            user.name,
                            style: TextStyle(
                              color: Color(getUserHexColor(user.level)),
                            ),
                          ),
                        );
                      },
                      childCount: state.favoriters.length,
                    ),
                  ),
                  if (state.loading)
                    const SliverToBoxAdapter(
                      child:
                          Center(child: CircularProgressIndicator.adaptive()),
                    ),
                ],
              ),
      ),
    );
  }
}
