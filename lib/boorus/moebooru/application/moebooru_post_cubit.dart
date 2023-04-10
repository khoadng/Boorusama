// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/posts.dart';

typedef MoebooruPostState = PostState<Post, MoebooruPostExtra>;

class MoebooruPostExtra extends Equatable {
  final String tag;
  final int? limit;

  const MoebooruPostExtra({
    required this.tag,
    this.limit,
  });

  @override
  List<Object?> get props => [tag, limit];

  MoebooruPostExtra copyWith({
    String? tag,
    int? Function()? limit,
  }) {
    return MoebooruPostExtra(
      tag: tag ?? this.tag,
      limit: limit != null ? limit() : this.limit,
    );
  }
}

class MoebooruPostCubit extends PostCubit<Post, MoebooruPostExtra> {
  MoebooruPostCubit({
    required MoebooruPostExtra extra,
    required this.postRepository,
  }) : super(initial: PostState.initial(extra));

  final PostRepository postRepository;

  @override
  Future<List<Post>> Function(int page) get fetcher =>
      (page) => postRepository.getPostsFromTags(
            state.extra.tag,
            page,
            limit: state.extra.limit,
          );

  @override
  Future<List<Post>> Function() get refresher =>
      () => postRepository.getPostsFromTags(
            state.extra.tag,
            1,
            limit: state.extra.limit,
          );

  void setTags(String tag) => emit(
        state.copyWith(extra: state.extra.copyWith(tag: tag)),
      );
}

mixin MoebooruPostCubitMixin<T extends StatefulWidget> on State<T> {
  void refresh() => context.read<MoebooruPostCubit>().refresh();
  void fetch() => context.read<MoebooruPostCubit>().fetch();
}
