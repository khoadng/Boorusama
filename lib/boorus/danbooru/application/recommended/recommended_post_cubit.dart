// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';

@immutable
abstract class RecommendedPostEvent extends Equatable {
  const RecommendedPostEvent();
}

class RecommendedPostRequested extends RecommendedPostEvent {
  const RecommendedPostRequested({
    required this.tags,
  });
  final List<String> tags;
  @override
  List<Object?> get props => [tags];
}

class RecommendedPostBloc
    extends Bloc<RecommendedPostEvent, AsyncLoadState<List<Recommended>>> {
  RecommendedPostBloc({
    required IPostRepository postRepository,
  }) : super(const AsyncLoadState.initial()) {
    on<RecommendedPostRequested>(
      (event, emit) async {
        await tryAsync<List<Recommended>>(
            action: () => Future.wait(
                    event.tags.where((tag) => tag.isNotEmpty).map((tag) async {
                  final posts = await postRepository.getPosts(tag, 1,
                      limit: 10, skipFavoriteCheck: true);

                  final recommended =
                      Recommended(title: tag, posts: posts.take(6).toList());

                  return recommended;
                }).toList()),
            onFailure: (stackTrace, error) =>
                emit(const AsyncLoadState.failure()),
            onLoading: () => emit(const AsyncLoadState.loading()),
            onSuccess: (posts) => emit(AsyncLoadState.success(posts)));
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
