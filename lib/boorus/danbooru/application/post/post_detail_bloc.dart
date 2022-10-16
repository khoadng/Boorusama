// Dart imports:
import 'dart:math';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';

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
  });

  factory PostDetailState.initial() => const PostDetailState(
        id: 0,
        tags: [],
      );

  final List<PostDetailTag> tags;

  //TODO: quick hack to force rebuild...
  final double id;

  PostDetailState copyWith({
    double? id,
    List<PostDetailTag>? tags,
  }) =>
      PostDetailState(
        id: id ?? this.id,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [tags, id];
}

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();
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
    required void Function(
      int postId,
      String tag,
      TagCategory tagCategory,
    )
        onPostUpdated,
  }) : super(PostDetailState(
          id: 0,
          tags: tags,
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
  }
}
