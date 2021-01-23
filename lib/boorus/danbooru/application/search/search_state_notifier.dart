import 'package:boorusama/boorus/danbooru/application/home/post_filter.dart';
import 'package:boorusama/boorus/danbooru/application/search/query_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.dart';
part 'search_state_notifier.freezed.dart';

final searchStateNotifierProvider =
    StateNotifierProvider<SearchStateNotifier>((ref) {
  return SearchStateNotifier(ref);
});

class SearchStateNotifier extends StateNotifier<SearchState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  final ProviderReference _ref;

  SearchStateNotifier(ProviderReference ref)
      : _postRepository = ref.watch(postProvider),
        _settingRepository = ref.watch(settingsProvider),
        _ref = ref,
        super(SearchState.initial());

  void search() async {
    state = state.copyWith(
      monitoringState:
          SearchMonitoringState.inProgress(loadingType: LoadingType.refresh),
      page: 1,
      posts: <Post>[],
    );

    final query = _ref
        .watch(queryStateNotifierProvider.state)
        .completedQueryItems
        .join(' ');
    final dtos = await _postRepository.getPosts(query, 1);
    final settings = await _settingRepository.load();
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

    final query = _ref.watch(queryStateNotifierProvider.state).query;
    final dtos = await _postRepository.getPosts(query, nextPage);
    final settings = await _settingRepository.load();
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
