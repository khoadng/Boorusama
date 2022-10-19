// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'slide_show_configuration.dart';

class PostDetailTag extends Equatable {
  const PostDetailTag({
    required this.name,
    required this.category,
    required this.postId,
  });

  final String name;
  final TagAutocompleteCategory category;
  final int postId;

  @override
  List<Object?> get props => [postId, name];
}

enum RecommendType {
  artist,
  character,
}

class Recommend extends Equatable {
  const Recommend({
    required this.title,
    required this.posts,
    required this.type,
  });

  final String title;
  final List<PostData> posts;
  final RecommendType type;

  @override
  List<Object?> get props => [title, posts, type];
}

class PostDetailState extends Equatable {
  const PostDetailState({
    required this.id,
    required this.tags,
    required this.currentIndex,
    required this.currentPost,
    this.enableSlideShow = false,
    required this.slideShowConfig,
    required this.recommends,
  });

  factory PostDetailState.initial() => PostDetailState(
        id: 0,
        tags: const [],
        currentIndex: 0,
        currentPost: PostData(post: Post.empty(), isFavorited: false),
        slideShowConfig: const SlideShowConfiguration(
          interval: 4,
          skipAnimation: false,
        ),
        recommends: const [],
      );

  final List<PostDetailTag> tags;
  final int currentIndex;
  final PostData currentPost;
  final bool enableSlideShow;
  final SlideShowConfiguration slideShowConfig;
  final List<Recommend> recommends;

  //TODO: quick hack to force rebuild...
  final double id;

  PostDetailState copyWith({
    double? id,
    List<PostDetailTag>? tags,
    int? currentIndex,
    PostData? currentPost,
    bool? enableSlideShow,
    SlideShowConfiguration? slideShowConfig,
    List<Recommend>? recommends,
  }) =>
      PostDetailState(
        id: id ?? this.id,
        tags: tags ?? this.tags,
        currentIndex: currentIndex ?? this.currentIndex,
        currentPost: currentPost ?? this.currentPost,
        enableSlideShow: enableSlideShow ?? this.enableSlideShow,
        slideShowConfig: slideShowConfig ?? this.slideShowConfig,
        recommends: recommends ?? this.recommends,
      );

  @override
  List<Object?> get props => [
        tags,
        id,
        currentIndex,
        currentPost,
        enableSlideShow,
        slideShowConfig,
        recommends,
      ];
}

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();
}

class PostDetailIndexChanged extends PostDetailEvent {
  const PostDetailIndexChanged({
    required this.index,
  });

  final int index;

  @override
  List<Object?> get props => [index];
}

class PostDetailFavoritesChanged extends PostDetailEvent {
  const PostDetailFavoritesChanged({
    required this.favorite,
  });

  final bool favorite;

  @override
  List<Object?> get props => [favorite];
}

class PostDetailModeChanged extends PostDetailEvent {
  const PostDetailModeChanged({
    required this.enableSlideshow,
  });

  final bool enableSlideshow;

  @override
  List<Object?> get props => [enableSlideshow];
}

class PostDetailSlideShowConfigChanged extends PostDetailEvent {
  const PostDetailSlideShowConfigChanged({
    required this.config,
  });

  final SlideShowConfiguration config;

  @override
  List<Object?> get props => [config];
}

class PostDetailTagUpdated extends PostDetailEvent {
  const PostDetailTagUpdated({
    required this.tag,
    required this.category,
    required this.postId,
  });

  final int? category;
  final String tag;
  final int postId;

  @override
  List<Object?> get props => [tag, category, postId];
}

class PostDetailUpvoted extends PostDetailEvent {
  const PostDetailUpvoted();

  @override
  List<Object?> get props => [];
}

class PostDetailDownvoted extends PostDetailEvent {
  const PostDetailDownvoted();

  @override
  List<Object?> get props => [];
}

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required PostRepository postRepository,
    required FavoritePostRepository favoritePostRepository,
    required AccountRepository accountRepository,
    required PostVoteRepository postVoteRepository,
    required List<PostDetailTag> tags,
    required int initialIndex,
    required List<PostData> posts,
    required void Function(
      int postId,
      String tag,
      TagCategory tagCategory,
    )
        onPostUpdated,
    double Function()? idGenerator,
  }) : super(PostDetailState(
          id: 0,
          tags: tags,
          currentIndex: initialIndex,
          currentPost: posts[initialIndex],
          slideShowConfig: PostDetailState.initial().slideShowConfig,
          recommends: const [],
        )) {
    on<PostDetailTagUpdated>((event, emit) async {
      if (event.category == null) return;

      await tryAsync<bool>(
        action: () => postRepository.putTag(event.postId, event.tag),
        onSuccess: (data) async {
          emit(state.copyWith(
            tags: [
              ...state.tags,
              PostDetailTag(
                name: event.tag,
                category: TagAutocompleteCategory(
                  category: TagCategory.values[event.category!],
                ),
                postId: event.postId,
              ),
            ]..sort((a, b) => a.name.compareTo(b.name)),
            id: idGenerator?.call() ?? Random().nextDouble(),
          ));

          onPostUpdated(
            event.postId,
            event.tag,
            TagCategory.values[event.category!],
          );
        },
      );
    });

    on<PostDetailIndexChanged>(
      (event, emit) async {
        final post = posts[event.index];
        emit(state.copyWith(
          currentIndex: event.index,
          currentPost: post,
          recommends: [],
        ));
        final account = await accountRepository.get();
        if (account != Account.empty) {
          unawaited(favoritePostRepository
              .checkIfFavoritedByUser(account.id, post.post.id)
              .then((fav) {
            if (!emit.isDone && fav) {
              emit(state.copyWith(
                  currentPost: PostData(post: post.post, isFavorited: true)));
            }
          }));

          unawaited(
              postVoteRepository.getPostVotes([post.post.id]).then((votes) {
            if (!emit.isDone && votes.isNotEmpty) {
              emit(state.copyWith(
                currentPost: post.copyWith(voteState: votes.first.voteState),
              ));
            }
          }));
        }

        for (final tag in post.post.artistTags) {
          final posts = await postRepository.getPosts(tag, 1);
          emit(state.copyWith(recommends: [
            ...state.recommends,
            Recommend(
              type: RecommendType.artist,
              title: tag,
              posts: posts
                  .take(6)
                  .map((e) => PostData(post: e, isFavorited: false))
                  .toList(),
            ),
          ]));
        }

        for (final tag in post.post.characterTags) {
          final posts = await postRepository.getPosts(tag, 1);
          emit(state.copyWith(recommends: [
            ...state.recommends,
            Recommend(
              type: RecommendType.character,
              title: tag,
              posts: posts
                  .take(6)
                  .map((e) => PostData(post: e, isFavorited: false))
                  .toList(),
            ),
          ]));
        }
      },
      transformer: restartable(),
    );

    on<PostDetailModeChanged>((event, emit) {
      emit(state.copyWith(
        enableSlideShow: event.enableSlideshow,
      ));
    });

    on<PostDetailSlideShowConfigChanged>((event, emit) {
      emit(state.copyWith(
        slideShowConfig: event.config,
      ));
    });

    on<PostDetailFavoritesChanged>((event, emit) async {
      var success = false;
      emit(state.copyWith(
        currentPost:
            PostData(post: state.currentPost.post, isFavorited: event.favorite),
      ));
      if (event.favorite) {
        success = await favoritePostRepository
            .addToFavorites(state.currentPost.post.id);
      } else {
        success = await favoritePostRepository
            .removeFromFavorites(state.currentPost.post.id);
      }
      if (!success) {
        emit(state.copyWith(
          currentPost: PostData(
              post: state.currentPost.post, isFavorited: !event.favorite),
        ));
      }
    });

    on<PostDetailUpvoted>((event, emit) async {
      final post = state.currentPost;
      final originalState = state;
      if (post.voteState == VoteState.upvoted) return;

      final up = post.post.upScore + 1;
      final down = post.voteState == VoteState.downvoted
          ? post.post.downScore + 1
          : post.post.downScore;
      emit(state.copyWith(
        currentPost: post.copyWith(
          post: post.post.copyWith(
            upScore: up,
            downScore: down,
          ),
          voteState: VoteState.upvoted,
        ),
      ));

      final vote = await postVoteRepository.upvote(post.post.id);

      if (vote == null) {
        emit(originalState);
      }
    });

    on<PostDetailDownvoted>((event, emit) async {
      final post = state.currentPost;
      final originalState = state;
      if (post.voteState == VoteState.downvoted) return;

      final down = post.post.downScore - 1;
      final up = post.voteState == VoteState.upvoted
          ? post.post.upScore - 1
          : post.post.upScore;
      emit(state.copyWith(
        currentPost: post.copyWith(
          post: post.post.copyWith(
            upScore: up,
            downScore: down,
          ),
          voteState: VoteState.downvoted,
        ),
      ));

      final vote = await postVoteRepository.downvote(post.post.id);

      if (vote == null) {
        emit(originalState);
      }
    });

    add(PostDetailIndexChanged(index: initialIndex));
  }
}
