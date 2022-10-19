// Dart imports:
import 'dart:math';

// Package imports:
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

class PostDetailState extends Equatable {
  const PostDetailState({
    required this.id,
    required this.tags,
    required this.currentIndex,
    required this.currentPost,
    this.enableSlideShow = false,
    required this.slideShowConfig,
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
      );

  final List<PostDetailTag> tags;
  final int currentIndex;
  final PostData currentPost;
  final bool enableSlideShow;
  final SlideShowConfiguration slideShowConfig;

  //TODO: quick hack to force rebuild...
  final double id;

  PostDetailState copyWith({
    double? id,
    List<PostDetailTag>? tags,
    int? currentIndex,
    PostData? currentPost,
    bool? enableSlideShow,
    SlideShowConfiguration? slideShowConfig,
  }) =>
      PostDetailState(
        id: id ?? this.id,
        tags: tags ?? this.tags,
        currentIndex: currentIndex ?? this.currentIndex,
        currentPost: currentPost ?? this.currentPost,
        enableSlideShow: enableSlideShow ?? this.enableSlideShow,
        slideShowConfig: slideShowConfig ?? this.slideShowConfig,
      );

  @override
  List<Object?> get props =>
      [tags, id, currentIndex, currentPost, enableSlideShow, slideShowConfig];
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
  }) : super(PostDetailState(
          id: 0,
          tags: tags,
          currentIndex: initialIndex,
          currentPost: posts[initialIndex],
          slideShowConfig: PostDetailState.initial().slideShowConfig,
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
            id: Random().nextDouble(),
          ));

          onPostUpdated(
            event.postId,
            event.tag,
            TagCategory.values[event.category!],
          );
        },
      );
    });

    on<PostDetailIndexChanged>((event, emit) {
      emit(state.copyWith(
        currentIndex: event.index,
        currentPost: posts[event.index],
      ));
    });

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
  }
}
