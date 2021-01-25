// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/post_filter.dart';
import 'package:boorusama/boorus/danbooru/application/home/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';

part 'favorites_state.dart';
part 'favorites_state_notifier.freezed.dart';

final favoritesStateNotifierProvider =
    StateNotifierProvider<FavoritesStateNotifier>((ref) {
  return FavoritesStateNotifier(ref);
});

class FavoritesStateNotifier extends StateNotifier<FavoritesState> {
  FavoritesStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider.future),
        _accountRepository = ref.read(accountProvider),
        super(FavoritesState.initial());

  final IPostRepository _postRepository;
  final Future<ISettingRepository> _settingRepository;
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
      final settingsRepo = await _settingRepository;
      final settings = await settingsRepo.load();
      final filteredPosts = filter(dtos, settings);

      state = state.copyWith(
        postsState: PostState.fetched(),
        posts: [...state.posts, ...filteredPosts],
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
      final settingsRepo = await _settingRepository;
      final settings = await settingsRepo.load();
      final filteredPosts = filter(dtos, settings);

      state = state.copyWith(
        posts: filteredPosts,
        postsState: PostState.fetched(),
      );
    } on DatabaseTimeOut {
      state = state.copyWith(
        postsState: PostState.error(),
      );
    }
  }
}
