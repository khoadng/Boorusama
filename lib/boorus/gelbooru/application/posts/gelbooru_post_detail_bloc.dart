// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/application/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/utils/bloc/bloc.dart';
import 'package:boorusama/utils/collection_utils.dart';

abstract class GelbooruPostDetailEvent extends Equatable {
  const GelbooruPostDetailEvent();
}

class PostDetailRequested extends GelbooruPostDetailEvent {
  const PostDetailRequested({
    required this.index,
  });

  final int index;

  @override
  List<Object?> get props => [index];
}

class GelbooruPostDetailRecommendedFetch extends GelbooruPostDetailEvent {
  const GelbooruPostDetailRecommendedFetch(this.tags);

  final List<Tag> tags;

  @override
  List<Object?> get props => [tags];
}

class GelbooruPostDetailBloc
    extends Bloc<GelbooruPostDetailEvent, GelbooruPostDetailState> {
  GelbooruPostDetailBloc({
    required PostRepository postRepository,
    required int initialIndex,
    required List<Post> posts,
    DetailsDisplay defaultDetailsStyle = DetailsDisplay.postFocus,
  }) : super(GelbooruPostDetailState(
          currentIndex: initialIndex,
          currentPost: posts[initialIndex],
          nextPost: posts.getOrNull(initialIndex + 1),
          previousPost: posts.getOrNull(initialIndex - 1),
          recommends: const [],
        )) {
    on<PostDetailRequested>(
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
        ));

        _loaded.add(event.index);
      },
      transformer: restartable(),
    );

    on<GelbooruPostDetailRecommendedFetch>(
      (event, emit) async {
        await _fetchArtistPosts(
          event.tags
              .where((e) => e.category == TagCategory.artist)
              .map((e) => e.rawName)
              .toList(),
          postRepository,
          emit,
          tagCache,
        );
      },
      transformer: debounce(const Duration(milliseconds: 500)),
    );
  }

  final _loaded = <int>{};
  final tagCache = <String, List<Post>>{};

  Future<void> _fetchArtistPosts(
    List<String> tags,
    PostRepository postRepository,
    Emitter<GelbooruPostDetailState> emit,
    Map<String, List<Post>> tagCache,
  ) async {
    for (final tag in tags) {
      if (state.recommends.any((e) => e.tag == tag)) continue;

      final posts = tagCache.containsKey(tag)
          ? tagCache[tag]!
          : await postRepository.getPostsFromTagsOrEmpty(tag, 1);

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
