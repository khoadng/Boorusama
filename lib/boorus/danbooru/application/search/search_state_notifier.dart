// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/post_filter.dart';
import 'package:boorusama/boorus/danbooru/application/search/query_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';

part 'search_state.dart';
part 'search_state_notifier.freezed.dart';

final searchStateNotifierProvider =
    StateNotifierProvider<SearchStateNotifier>((ref) {
  return SearchStateNotifier(ref);
});

class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier(ProviderReference ref)
      : _postRepository = ref.watch(postProvider),
        _settingRepository = ref.watch(settingsProvider.future),
        _ref = ref,
        super(SearchState.initial());

  final IPostRepository _postRepository;
  final ProviderReference _ref;
  final Future<ISettingRepository> _settingRepository;

  void search() async {
    state = state.copyWith(
      monitoringState:
          SearchMonitoringState.inProgress(loadingType: LoadingType.refresh),
      page: 1,
      posts: <Post>[],
    );

    final completedQueryItems =
        _ref.watch(queryStateNotifierProvider.state).completedQueryItems;
    final query = completedQueryItems.join(' ');

    final dtos = await _postRepository.getPosts(query, 1);
    final settingsRepo = await _settingRepository;
    final settings = await settingsRepo.load();
    final filteredPosts = filter(dtos, settings);

    state = state.copyWith(
      monitoringState: SearchMonitoringState.completed(),
      posts: filteredPosts,
    );
  }

  void getMoreResult() async {
    final nextPage = state.page + 1;

    state = state.copyWith(
      monitoringState:
          SearchMonitoringState.inProgress(loadingType: LoadingType.more),
      page: nextPage,
    );

    final completedQueryItems =
        _ref.watch(queryStateNotifierProvider.state).completedQueryItems;
    final query = completedQueryItems.join(' ');
    final dtos = await _postRepository.getPosts(query, nextPage);
    final settingsRepo = await _settingRepository;
    final settings = await settingsRepo.load();
    final filteredPosts = filter(dtos, settings);

    state = state.copyWith(
      monitoringState: SearchMonitoringState.completed(),
      posts: [...state.posts, ...filteredPosts],
    );
  }

  void clear() {
    state = SearchState.initial();
  }
}
