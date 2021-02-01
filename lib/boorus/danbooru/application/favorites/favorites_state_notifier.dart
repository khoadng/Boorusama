// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/core/application/list_state_notifier.dart';

part 'favorites_state.dart';
part 'favorites_state_notifier.freezed.dart';

final favoritesStateNotifierProvider =
    StateNotifierProvider<FavoritesStateNotifier>((ref) {
  return FavoritesStateNotifier(ref)..refresh();
});

class FavoritesStateNotifier extends StateNotifier<FavoritesState> {
  FavoritesStateNotifier(ProviderReference ref)
      : _postRepository = ref.watch(postProvider),
        _listStateNotifier = ListStateNotifier<Post>(),
        _accountRepository = ref.watch(accountProvider),
        super(FavoritesState.initial());

  final IPostRepository _postRepository;
  final IAccountRepository _accountRepository;
  final ListStateNotifier<Post> _listStateNotifier;

  void getMorePosts() async {
    _listStateNotifier.getMoreItems(
      callback: () async {
        final nextPage = state.posts.page + 1;
        final account = await _accountRepository.get();
        final dtos =
            await _postRepository.getPosts("fav:${account.username}", nextPage);
        final posts = dtos.map((dto) => dto.toEntity()).toList();

        return posts;
      },
      onStateChanged: (state) => this.state = this.state.copyWith(
            posts: state,
          ),
    );
  }

  void refresh() async {
    _listStateNotifier.refresh(
      callback: () async {
        final account = await _accountRepository.get();
        final dtos =
            await _postRepository.getPosts("fav:${account.username}", 1);
        final posts = dtos.map((dto) => dto.toEntity()).toList();

        return posts;
      },
      onStateChanged: (state) {
        if (mounted) {
          this.state = this.state.copyWith(
                posts: state,
              );
        }
      },
    );
  }

  void viewPost(Post post) {
    _listStateNotifier.view(
        item: post,
        onStateChanged: (state) => this.state = this.state.copyWith(
              posts: state,
            ));
  }

  void stopViewing() {
    _listStateNotifier.stopViewing(
        lastIndexBuilder: () => state.posts.items
            .indexWhere((p) => p.id == state.posts.currentViewingItem.id),
        onStateChanged: (state) => this.state = this.state.copyWith(
              posts: state,
            ));
  }
}
