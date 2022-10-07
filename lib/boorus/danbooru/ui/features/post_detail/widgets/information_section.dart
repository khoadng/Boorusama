// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post_favorite_info_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_vote_info_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_level.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'post_info.dart';

class InformationSection extends StatelessWidget {
  const InformationSection({
    Key? key,
    required this.post,
    this.tappable = true,
    this.padding,
  }) : super(key: key);

  final Post post;
  final bool tappable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConditionalParentWidget(
          condition: tappable,
          conditionalBuilder: (child) => InkWell(
            onTap: () => showMaterialModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => PostInfo(
                  post: post,
                  scrollController: ModalScrollController.of(context)!),
            ),
            child: child,
          ),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.characterTags.isEmpty
                            ? 'Original'
                            : post.name.characterOnly
                                .removeUnderscoreWithSpace()
                                .titleCase,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 5),
                      Text(
                          post.copyrightTags.isEmpty
                              ? 'Original'
                              : post.name.copyRightOnly
                                  .removeUnderscoreWithSpace()
                                  .titleCase,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.bodyText2),
                      const SizedBox(height: 5),
                      Text(
                        dateTimeToStringTimeAgo(
                          post.createdAt,
                          locale: Localizations.localeOf(context).languageCode,
                        ),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                if (tappable)
                  const Flexible(child: Icon(Icons.keyboard_arrow_down))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                child: Html(
                  shrinkWrap: true,
                  style: {
                    'b': Style(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                    'span': Style(
                      color: Theme.of(context).hintColor,
                      fontSize: FontSize.small,
                    ),
                    'body': Style(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                    ),
                  },
                  data: '<b>${post.favCount}</b> <span>Favorites</span>',
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
                child: Html(
                    shrinkWrap: true,
                    style: {
                      'b': Style(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                      'span': Style(
                        color: Theme.of(context).hintColor,
                        fontSize: FontSize.small,
                      ),
                      'body': Style(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                      ),
                    },
                    data:
                        '<b>${post.score}</b> <span>Points ${_generatePercentText(post)}</span>'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({
    Key? key,
    required this.child,
    required this.enable,
    required this.onTap,
  }) : super(key: key);

  final Widget child;
  final bool enable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: enable,
      conditionalBuilder: (child) => InkWell(
        onTap: onTap,
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
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
                      final user = state.upvoters[index];
                      return ListTile(
                        title: Text(
                          user.name.value,
                          style: TextStyle(color: Color(user.level.hexColor)),
                        ),
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
