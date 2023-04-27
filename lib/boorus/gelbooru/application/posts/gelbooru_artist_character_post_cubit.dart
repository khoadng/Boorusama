// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/posts.dart';

typedef GelbooruArtistCharacterPostState
    = PostState<Post, GelbooruArtistChararacterExtra>;

class GelbooruArtistChararacterExtra extends Equatable {
  final TagFilterCategory category;
  final String tag;

  const GelbooruArtistChararacterExtra({
    required this.category,
    required this.tag,
  });

  @override
  List<Object?> get props => [category, tag];

  GelbooruArtistChararacterExtra copyWith({
    TagFilterCategory? category,
    String? tag,
  }) {
    return GelbooruArtistChararacterExtra(
      category: category ?? this.category,
      tag: tag ?? this.tag,
    );
  }
}

class GelbooruArtistCharacterPostCubit
    extends PostCubit<Post, GelbooruArtistChararacterExtra> {
  GelbooruArtistCharacterPostCubit({
    required GelbooruArtistChararacterExtra extra,
    PostPreviewPreloader? previewPreloader,
    required this.postRepository,
  }) : super(initial: PostState.initial(extra));

  factory GelbooruArtistCharacterPostCubit.of(
    BuildContext context, {
    required GelbooruArtistChararacterExtra extra,
  }) =>
      GelbooruArtistCharacterPostCubit(
        extra: extra,
        postRepository: context.read<PostRepository>(),
      );

  final PostRepository postRepository;

  @override
  Future<List<Post>> Function(int page) get fetcher =>
      (page) => postRepository.getPostsFromTags(
            _extraToTagString(state.extra),
            page,
          );

  @override
  Future<List<Post>> Function() get refresher =>
      () => postRepository.getPostsFromTags(
            _extraToTagString(state.extra),
            1,
          );

  void changeCategory(TagFilterCategory category) => emit(state.copyWith(
        extra: state.extra.copyWith(
          category: category,
        ),
      ));
}

String _extraToTagString(GelbooruArtistChararacterExtra extra) => [
      _tagFilterCategoryToString(extra.category),
      extra.tag,
    ].whereNotNull().join(' ');

String? _tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? "sort:score:desc" : null;

mixin GelbooruArtistCharacterPostCubitMixin on StatelessWidget {
  void refresh(BuildContext context) =>
      context.read<GelbooruArtistCharacterPostCubit>().refresh();
  void fetch(BuildContext context) =>
      context.read<GelbooruArtistCharacterPostCubit>().fetch();
  void changeCategory(
    BuildContext context,
    TagFilterCategory category,
  ) {
    final cubit = context.read<GelbooruArtistCharacterPostCubit>();
    cubit.changeCategory(category);
    cubit.refresh();
  }
}
