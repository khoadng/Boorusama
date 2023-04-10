// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/common.dart';

class FavoritesCubit extends Cubit<AsyncLoadState<List<DanbooruPost>>> {
  FavoritesCubit({
    required this.postRepository,
  }) : super(const AsyncLoadState.initial());

  final DanbooruPostRepository postRepository;

  void getUserFavoritePosts(String username) {
    tryAsync<List<DanbooruPost>>(
      action: () => postRepository.getPosts('ordfav:$username', 1),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onSuccess: (posts) async => emit(AsyncLoadState.success(posts)),
    );
  }
}
