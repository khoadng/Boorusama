// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
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
  return FavoritesStateNotifier(removedNullImageRepo, accountRepo)..refresh();
});

class FavoritesStateNotifier extends StateNotifier<FavoritesState> {
  FavoritesStateNotifier(
      IPostRepository postRepository, IAccountRepository accountRepository)
      : _postRepository = postRepository,
        _accountRepository = accountRepository,
        super(FavoritesState.initial());

  final IPostRepository _postRepository;
  final IAccountRepository _accountRepository;

  void getMorePosts() async {
    try {
      final nextPage = state.page + 1;
      state = state.copyWith(
        postsState: PostState.loading(),
      );

      final account = await _accountRepository.get();
      final dtos =
          await _postRepository.getPosts("fav:${account.username}", nextPage);
      final posts = dtos.map((dto) => dto.toEntity()).toList();

      state = state.copyWith(
        postsState: PostState.fetched(),
        posts: [...state.posts, ...posts],
        page: nextPage,
      );
    } on DatabaseTimeOut {
      state = state.copyWith(
        postsState: PostState.error(),
      );
    }
  }

  void refresh() async {
    try {
      state = state.copyWith(
        page: 1,
        posts: [],
        postsState: PostState.refreshing(),
      );

      final account = await _accountRepository.get();
      final dtos = await _postRepository.getPosts("fav:${account.username}", 1);
      final posts = dtos.map((dto) => dto.toEntity()).toList();

      if (mounted) {
        state = state.copyWith(
          posts: posts,
          postsState: PostState.fetched(),
        );
      }
    } on DatabaseTimeOut {
      state = state.copyWith(
        postsState: PostState.error(),
      );
    }
  }
}
