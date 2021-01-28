// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/core/application/list_state_notifier.dart';
import '../black_listed_filter_decorator.dart';
import '../no_image_filter_decorator.dart';

part 'favorites_state.dart';
part 'favorites_state_notifier.freezed.dart';

final favoritesStateNotifierProvider =
    StateNotifierProvider<FavoritesStateNotifier>((ref) {
  final postRepo = ref.watch(postProvider);
  final settingsRepo = ref.watch(settingsProvider.future);
  final accountRepo = ref.watch(accountProvider);

  final filteredPostRepo = BlackListedFilterDecorator(
      postRepository: postRepo, settingRepository: settingsRepo);
  final removedNullImageRepo =
      NoImageFilterDecorator(postRepository: filteredPostRepo);
  final listStateNotifier = ListStateNotifier<Post>();
  return FavoritesStateNotifier(
      removedNullImageRepo, accountRepo, listStateNotifier)
    ..refresh();
});

class FavoritesStateNotifier extends StateNotifier<FavoritesState> {
  FavoritesStateNotifier(
    IPostRepository postRepository,
    IAccountRepository accountRepository,
    ListStateNotifier<Post> listStateNotifier,
  )   : _postRepository = postRepository,
        _accountRepository = accountRepository,
        _listStateNotifier = listStateNotifier,
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
    state = state.copyWith(
      lastViewedPost: state.currentViewingPost,
      currentViewingPost: post,
    );
  }

  void stopViewing() {
    state = state.copyWith(
      lastViewedPost: state.currentViewingPost,
      currentViewingPost: null,
    );
  }
}
