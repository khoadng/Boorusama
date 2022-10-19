// Dart imports:
import 'dart:math';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocomplete.dart';
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

class Recommend {
  const Recommend({
    required this.title,
    required this.posts,
    required this.type,
  });

  final String title;
  final List<PostData> posts;
  final RecommendType type;
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

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required PostRepository postRepository,
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
        emit(state.copyWith(
          currentIndex: event.index,
          currentPost: posts[event.index],
          recommends: [],
        ));

        for (final tag in posts[event.index].post.artistTags) {
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

        for (final tag in posts[event.index].post.characterTags) {
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

    add(PostDetailIndexChanged(index: initialIndex));
  }
}
