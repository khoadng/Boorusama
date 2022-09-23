// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';
import 'package:boorusama/core/core.dart';

@immutable
abstract class RecommendedPostEvent extends Equatable {
  const RecommendedPostEvent();
}

class RecommendedPostRequested extends RecommendedPostEvent {
  const RecommendedPostRequested({
    required this.tags,
    required this.currentPostId,
    required this.amount,
  });

  final List<String> tags;
  final int currentPostId;
  final int amount;

  @override
  List<Object?> get props => [tags, currentPostId, amount];
}

class RecommendedPostBloc
    extends Bloc<RecommendedPostEvent, AsyncLoadState<List<Recommended>>> {
  RecommendedPostBloc({
    required IPostRepository postRepository,
  }) : super(const AsyncLoadState.initial()) {
    on<RecommendedPostRequested>(
      (event, emit) async {
        await tryAsync<List<Recommended?>>(
            action: () => Future.wait(
                    event.tags.where((tag) => tag.isNotEmpty).map((tag) async {
                  final posts = await postRepository.getPosts(
                    tag,
                    1,
                    limit: 10,
                    skipFavoriteCheck: true,
                  );

                  final filtered = [...posts]
                    ..removeWhere((e) => e.id == event.currentPostId);

                  if (filtered.isEmpty) return null;

                  return Recommended(
                    tag: tag,
                    title:
                        tag.split(' ').join(', ').removeUnderscoreWithSpace(),
                    posts: filtered
                        .take(event.amount)
                        .map((e) => PostData(post: e, isFavorited: false))
                        .toList(),
                  );
                }).toList()),
            onFailure: (stackTrace, error) =>
                emit(const AsyncLoadState.failure()),
            onLoading: () => emit(const AsyncLoadState.loading()),
            onSuccess: (posts) async =>
                emit(AsyncLoadState.success(posts.whereNotNull().toList())));
      },
      transformer: debounceRestartable(const Duration(milliseconds: 150)),
    );
  }
}

class RecommendedArtistPostCubit extends RecommendedPostBloc {
  RecommendedArtistPostCubit({required IPostRepository postRepository})
      : super(postRepository: postRepository);
}

class RecommendedCharacterPostCubit extends RecommendedPostBloc {
  RecommendedCharacterPostCubit({required IPostRepository postRepository})
      : super(postRepository: postRepository);
}
