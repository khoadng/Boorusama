// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/utils/bloc/bloc.dart';
import 'package:boorusama/utils/collection_utils.dart';

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

class _PostDetailPoolFetch extends PostDetailEvent {
  const _PostDetailPoolFetch(this.postId);

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required NoteRepository noteRepository,
    required DanbooruPostRepository postRepository,
    required PoolRepository poolRepository,
    required CurrentBooruConfigRepository currentBooruConfigRepository,
    required BooruUserIdentityProvider booruUserIdentityProvider,
    required PostVoteRepository postVoteRepository,
    required List<PostDetailTag> tags,
    required int initialIndex,
    required List<DanbooruPost> posts,
    required Map<String, List<DanbooruPost>> tagCache,
    void Function(
      DanbooruPost post,
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
          pools: const [],
          notes: const [],
          fullScreen: defaultDetailsStyle != DetailsDisplay.postFocus,
        )) {
    on<PostDetailIndexChanged>(
      (event, emit) async {
        if (_loaded.contains(event.index)) return;

        final post = posts[event.index];
        final nextPost = posts.getOrNull(event.index + 1);
        final prevPost = posts.getOrNull(event.index - 1);

        emit(state.copyWith(
          currentIndex: event.index,
          currentPost: post,
          nextPost: () => nextPost,
          previousPost: () => prevPost,
          recommends: [],
          pools: [],
          notes: [],
        ));

        if (post.isTranslated) {
          add(_PostDetailNoteFetch(post.id));
        }

        add(_PostDetailPoolFetch(post.id));

        add(_PostDetailRecommendedFetch(
          post.artistTags,
          post.characterTags,
        ));

        _loaded.add(event.index);
      },
      transformer: restartable(),
    );

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

    if (fireIndexChangedAtStart) {
      add(PostDetailIndexChanged(index: initialIndex));
    }

    on<PostDetailDisplayModeChanged>((event, emit) async {
      emit(state.copyWith(
        fullScreen: event.fullScreen,
      ));
      if (!event.fullScreen && state.recommends.isEmpty) {
        await _fetchArtistPosts(
          state.currentPost.artistTags,
          postRepository,
          emit,
          tagCache,
        );
        await _fetchCharactersPosts(
          state.currentPost.characterTags,
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

    on<_PostDetailPoolFetch>((event, emit) async {
      final pools = await poolRepository.getPoolsByPostId(event.postId);

      emit(state.copyWith(pools: pools));
    });

    on<_PostDetailNoteFetch>((event, emit) async {
      final notes = await noteRepository.getNotesFrom(event.postId);

      emit(state.copyWith(notes: notes));
    });
  }

  final _loaded = <int>{};

  Future<void> _fetchCharactersPosts(
    List<String> tags,
    DanbooruPostRepository postRepository,
    Emitter<PostDetailState> emit,
    Map<String, List<DanbooruPost>> tagCache,
  ) async {
    for (final tag in tags) {
      final posts = tagCache.containsKey(tag)
          ? tagCache[tag]!
          : await postRepository.getPosts(tag, 1);

      tagCache[tag] = posts;

      emit(state.copyWith(
        recommends: [
          ...state.recommends,
          Recommend(
            type: RecommendType.character,
            title: tag.removeUnderscoreWithSpace(),
            tag: tag,
            posts: posts.where((e) => !e.isFlash).toList(),
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
          : await postRepository.getPosts(tag, 1);

      tagCache[tag] = posts;

      emit(state.copyWith(
        recommends: [
          ...state.recommends,
          Recommend(
            type: RecommendType.artist,
            title: tag.removeUnderscoreWithSpace(),
            tag: tag,
            posts: posts.where((e) => !e.isFlash).toList(),
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
