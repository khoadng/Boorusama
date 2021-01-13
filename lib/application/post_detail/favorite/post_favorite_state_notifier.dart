import 'package:boorusama/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/infrastructure/repositories/accounts/favorite_post_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_favorite_state.dart';
part 'post_favorite_state_notifier.freezed.dart';

class PostFavoriteStateNotifier extends StateNotifier<PostFavoriteState> {
  final IFavoritePostRepository _favoritePostRepository;

  PostFavoriteStateNotifier(ProviderReference ref)
      : _favoritePostRepository = ref.read(favoriteProvider),
        super(PostFavoriteState.initial());

  void favorite(int postId) async {
    state = PostFavoriteState.loading();

    final success = await _favoritePostRepository.addToFavorites(postId);

    if (success) {
      state = PostFavoriteState.success();
    } else {
      state = PostFavoriteState.error(
          name: "Error", message: "Something went wrong");
    }
  }

  void unfavorite(int postId) async {
    state = PostFavoriteState.loading();

    final success = await _favoritePostRepository.removeFromFavorites(postId);

    if (success) {
      state = PostFavoriteState.success();
    } else {
      state = PostFavoriteState.error(
          name: "Error", message: "Something went wrong");
    }
  }
}
