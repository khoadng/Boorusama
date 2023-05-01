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

  Future<void> getUserFavoritePosts(String username) async {
    emit(const AsyncLoadState.loading());
    await postRepository.getPosts('ordfav:$username', 1).run().then(
          (value) => value.fold(
            (e) => emit(const AsyncLoadState.failure()),
            (r) => emit(AsyncLoadState.success(r)),
          ),
        );
  }
}
