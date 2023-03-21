// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/common/bloc/bloc.dart';
import 'package:boorusama/common/collection_utils.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags/tags.dart';

class _PostDetailFavoriteFetch extends PostDetailEvent {
  const _PostDetailFavoriteFetch(this.accountId);

  final int accountId;

  @override
  List<Object?> get props => [accountId];
}

class _PostDetailVoteFetch extends PostDetailEvent {
  const _PostDetailVoteFetch();

  @override
  List<Object?> get props => [];
}

class _PostDetailRecommendedFetch extends PostDetailEvent {
  const _PostDetailRecommendedFetch(this.artistTags, this.characterTags);

  final List<String> artistTags;
  final List<String> characterTags;

  @override
  List<Object?> get props => [artistTags, characterTags];
}

class _PostDetailNoteFetch extends PostDetailEvent {
  const _PostDetailNoteFetch(this.postId);

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required NoteRepository noteRepository,
    required DanbooruPostRepository postRepository,
    required FavoritePostRepository favoritePostRepository,
    required CurrentUserBooruRepository currentUserBooruRepository,
    required PostVoteRepository postVoteRepository,
    required List<PostDetailTag> tags,
    required int initialIndex,
    required List<DanbooruPostData> posts,
    required Map<String, List<DanbooruPost>> tagCache,
    void Function(
      DanbooruPostData post,
    )?
        onPostChanged,
    double Function()? idGenerator,
    bool fireIndexChangedAtStart = true,
    DetailsDisplay defaultDetailsStyle = DetailsDisplay.postFocus,
  }) : super(PostDetailState(
          id: 0,
          tags: tags,
          currentIndex: initialIndex,
          currentPost: posts[initialIndex],
          nextPost: posts.getOrNull(initialIndex + 1),
          previousPost: posts.getOrNull(initialIndex - 1),
          slideShowConfig: PostDetailState.initial().slideShowConfig,
          recommends: const [],
          fullScreen: defaultDetailsStyle != DetailsDisplay.postFocus,
        )) {
    on<PostDetailIndexChanged>(
      (event, emit) async {
        final post = posts[event.index];
        final nextPost = posts.getOrNull(event.index + 1);
        final prevPost = posts.getOrNull(event.index - 1);

        emit(state.copyWith(
          currentIndex: event.index,
          currentPost: post,
          nextPost: () => nextPost,
          previousPost: () => prevPost,
          recommends: [],
        ));
        final userBooru = await currentUserBooruRepository.get();
        if (userBooru.hasLoginDetails()) {
          add(_PostDetailFavoriteFetch(userBooru!.booruUserId!));
          add(const _PostDetailVoteFetch());
        }

        if (post.post.isTranslated) {
          add(_PostDetailNoteFetch(post.post.id));
          if (nextPost?.post.isTranslated ?? false) {
            // prefetch next post
            unawaited(Future.delayed(
              const Duration(milliseconds: 200),
              () => noteRepository.getNotesFrom(nextPost!.post.id),
            ));
          }
        }

        add(_PostDetailRecommendedFetch(
          post.post.artistTags,
          post.post.characterTags,
        ));
      },
      transformer: restartable(),
    );

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
                category: event.category!,
                postId: event.postId,
              ),
            ]..sort((a, b) => a.name.compareTo(b.name)),
            id: idGenerator?.call() ?? Random().nextDouble(),
          ));

          final post = posts.firstOrNull((e) => e.post.id == event.postId);
          if (post != null) {
            final newPost = post.copyWith(
              post: _newPost(
                post.post,
                event.tag,
                stringToTagCategory(event.category!),
              ),
            );

            onPostChanged?.call(newPost);
          }
        },
      );
    });

    on<_PostDetailRecommendedFetch>(
      (event, emit) async {
        if (!state.fullScreen) {
          await _fetchArtistPosts(
            event.artistTags,
            postRepository,
            emit,
            tagCache,
          );
          await _fetchCharactersPosts(
            event.characterTags,
            postRepository,
            emit,
            tagCache,
          );
        }
      },
      transformer: debounce(const Duration(milliseconds: 500)),
    );

    on<_PostDetailFavoriteFetch>(
      (event, emit) async {
        await favoritePostRepository
            .checkIfFavoritedByUser(event.accountId, state.currentPost.post.id)
            .then((fav) {
          emit(state.copyWith(
            currentPost: state.currentPost.copyWith(isFavorited: fav),
          ));
        });
      },
      transformer: debounceRestartable(const Duration(milliseconds: 300)),
    );

    on<_PostDetailVoteFetch>(
      (event, emit) async {
        await postVoteRepository
            .getPostVotes([state.currentPost.post.id]).then((votes) {
          if (votes.isNotEmpty) {
            emit(state.copyWith(
              currentPost:
                  state.currentPost.copyWith(voteState: votes.first.voteState),
            ));
          }
        });
      },
      transformer: debounceRestartable(const Duration(milliseconds: 300)),
    );

    on<_PostDetailNoteFetch>(
      (event, emit) async {
        final notes = await noteRepository.getNotesFrom(event.postId);

        emit(state.copyWith(
          currentPost: state.currentPost.copyWith(notes: notes),
        ));
      },
      transformer: debounceRestartable(const Duration(milliseconds: 300)),
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
      final userBooru = await currentUserBooruRepository.get();
      if (!userBooru.hasLoginDetails()) return;

      var success = false;
      final originalState = state;
      final post = state.currentPost;
      final newPost = state.currentPost.copyWith(
        post: post.post.copyWith(
          favCount: post.post.favCount + (event.favorite ? 1 : 0),
          score: post.post.score + (event.favorite ? 1 : 0),
          upScore: post.post.upScore + (event.favorite ? 1 : 0),
        ),
        isFavorited: event.favorite,
        voteState: event.favorite
            ? VoteState.upvoted
            : post.voteState == VoteState.upvoted
                ? VoteState.unvote
                : post.voteState,
      );

      posts[state.currentIndex] = newPost;
      emit(state.copyWith(
        currentPost: newPost,
      ));

      success = event.favorite
          ? await favoritePostRepository.addToFavorites(post.post.id)
          : await favoritePostRepository.removeFromFavorites(post.post.id);

      if (!success) {
        emit(originalState);
        posts[state.currentIndex] = post;
      }

      onPostChanged?.call(newPost);
    });

    on<PostDetailUpvoted>((event, emit) async {
      final post = state.currentPost;
      final originalState = state;
      if (post.voteState == VoteState.upvoted) return;

      final up = post.post.upScore + 1;
      final down = post.voteState == VoteState.downvoted
          ? post.post.downScore + 1
          : post.post.downScore;

      final newPost = post.copyWith(
        post: post.post.copyWith(
          score: post.post.score + 1,
          upScore: up,
          downScore: down,
        ),
        voteState: VoteState.upvoted,
      );

      posts[state.currentIndex] = newPost;

      emit(state.copyWith(
        currentPost: newPost,
      ));

      final vote = await postVoteRepository.upvote(post.post.id);

      if (vote == null) {
        emit(originalState);
        posts[state.currentIndex] = post;
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

      final newPost = post.copyWith(
        post: post.post.copyWith(
          score: post.post.score - 1,
          upScore: up,
          downScore: down,
        ),
        voteState: VoteState.downvoted,
      );

      posts[state.currentIndex] = newPost;

      emit(state.copyWith(
        currentPost: newPost,
      ));

      final vote = await postVoteRepository.downvote(post.post.id);

      if (vote == null) {
        emit(originalState);
        posts[state.currentIndex] = post;
      }
    });
    if (fireIndexChangedAtStart) {
      add(PostDetailIndexChanged(index: initialIndex));
    }

    on<PostDetailDisplayModeChanged>((event, emit) async {
      emit(state.copyWith(
        fullScreen: event.fullScreen,
      ));
      if (!event.fullScreen && state.recommends.isEmpty) {
        await _fetchArtistPosts(
          state.currentPost.post.artistTags,
          postRepository,
          emit,
          tagCache,
        );
        await _fetchCharactersPosts(
          state.currentPost.post.characterTags,
          postRepository,
          emit,
          tagCache,
        );
      }
    });

    on<PostDetailNoteOptionsChanged>((event, emit) {
      emit(state.copyWith(
        enableNotes: event.enable,
      ));
    });

    on<PostDetailOverlayVisibilityChanged>((event, emit) {
      if (!state.fullScreen) return;

      emit(state.copyWith(
        enableOverlay: event.enableOverlay,
      ));
    });
  }

  Future<void> _fetchCharactersPosts(
    List<String> tags,
    DanbooruPostRepository postRepository,
    Emitter<PostDetailState> emit,
    Map<String, List<DanbooruPost>> tagCache,
  ) async {
    for (final tag in tags) {
      final posts = tagCache.containsKey(tag)
          ? tagCache[tag]!
          : await postRepository.getPosts(tag, 1, limit: 20);

      tagCache[tag] = posts;

      emit(state.copyWith(
        recommends: [
          ...state.recommends,
          Recommend(
            type: RecommendType.character,
            title: tag,
            posts: posts
                .where((e) => !e.isFlash)
                .take(6)
                .map((e) => DanbooruPostData(
                      post: e,
                      isFavorited: false,
                      pools: const [],
                    ))
                .toList(),
          ),
        ],
      ));
    }
  }

  Future<void> _fetchArtistPosts(
    List<String> tags,
    DanbooruPostRepository postRepository,
    Emitter<PostDetailState> emit,
    Map<String, List<DanbooruPost>> tagCache,
  ) async {
    for (final tag in tags) {
      final posts = tagCache.containsKey(tag)
          ? tagCache[tag]!
          : await postRepository.getPosts(tag, 1, limit: 20);

      tagCache[tag] = posts;

      emit(state.copyWith(
        recommends: [
          ...state.recommends,
          Recommend(
            type: RecommendType.artist,
            title: tag,
            posts: posts
                .where((e) => !e.isFlash)
                .take(6)
                .map((e) => DanbooruPostData(
                      post: e,
                      isFavorited: false,
                      pools: const [],
                    ))
                .toList(),
          ),
        ],
      ));
    }
  }
}

extension PostDetailStateX on PostDetailState {
  bool shouldShowFloatingActionBar(ActionBarDisplayBehavior behavior) {
    if (enableSlideShow) return false;
    if (!enableOverlay) return false;

    // ignore: avoid_bool_literals_in_conditional_expressions
    return behavior == ActionBarDisplayBehavior.staticAtBottom
        ? true
        : fullScreen;
  }
}

DanbooruPost _newPost(DanbooruPost post, String tag, TagCategory category) {
  if (category == TagCategory.artist) {
    return post.copyWith(
      artistTags: [...post.artistTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  } else if (category == TagCategory.copyright) {
    return post.copyWith(
      copyrightTags: [...post.copyrightTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  } else if (category == TagCategory.charater) {
    return post.copyWith(
      characterTags: [...post.characterTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  } else if (category == TagCategory.meta) {
    return post.copyWith(
      metaTags: [...post.metaTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  } else {
    return post.copyWith(
      generalTags: [...post.generalTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  }
}
