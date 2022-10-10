// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post_favorite_info_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_vote_info_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_level.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

class PostStatsTile extends StatelessWidget {
  const PostStatsTile({
    Key? key,
    required this.post,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : super(key: key);

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
                create: (context) => PostFavoriteInfoBloc(
                  favoritePostRepository:
                      context.read<IFavoritePostRepository>(),
                  userRepository: context.read<IUserRepository>(),
                )..add(PostFavoriteInfoFetched(
                    postId: post.id,
                    refresh: true,
                  )),
                child: FavoriterView(
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
                    text: 'Favorites',
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
                  userRepository: context.read<IUserRepository>(),
                )..add(PostVoteInfoFetched(
                    postId: post.id,
                    refresh: true,
                  )),
                child: VoterView(
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
                    text: 'Points ${_generatePercentText(post)}',
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
                    text: 'comment.comments'.tr(),
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
    Key? key,
    required this.child,
    required this.enable,
    this.onTap,
  }) : super(key: key);

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
  if (post.totalVote > 0) {
    return '(${(post.upvotePercent * 100).toInt()}% upvoted)';
  } else {
    return '';
  }
}

class VoterView extends StatefulWidget {
  const VoterView({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<VoterView> createState() => _VoterViewState();
}

class _VoterViewState extends State<VoterView> {
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
          )
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
                      return InfoTile(
                        title: voter.user.name.value,
                        level: voter.user.level,
                      );
                    },
                    childCount: state.upvoters.length,
                  )),
                  if (state.loading)
                    const SliverToBoxAdapter(
                      child:
                          Center(child: CircularProgressIndicator.adaptive()),
                    )
                ],
              ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    Key? key,
    required this.title,
    required this.level,
  }) : super(key: key);

  final String title;
  final UserLevel level;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.comfortable,
      title: Text(
        title,
        style: TextStyle(color: Color(level.hexColor)),
      ),
    );
  }
}

class FavoriterView extends StatefulWidget {
  const FavoriterView({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<FavoriterView> createState() => _FavoriterViewState();
}

class _FavoriterViewState extends State<FavoriterView> {
  final scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (_isBottom) {
        context
            .read<PostFavoriteInfoBloc>()
            .add(PostFavoriteInfoFetched(postId: widget.post.id));
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
          )
        ],
      ),
      body: BlocBuilder<PostFavoriteInfoBloc, PostFavoriteInfoState>(
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
                          user.name.value,
                          style: TextStyle(color: Color(user.level.hexColor)),
                        ),
                      );
                    },
                    childCount: state.favoriters.length,
                  )),
                  if (state.loading)
                    const SliverToBoxAdapter(
                      child:
                          Center(child: CircularProgressIndicator.adaptive()),
                    )
                ],
              ),
      ),
    );
  }
}
