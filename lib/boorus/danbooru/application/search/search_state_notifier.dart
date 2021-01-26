// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/query_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import '../black_listed_filter_decorator.dart';
import '../no_image_filter_decorator.dart';

part 'search_state.dart';
part 'search_state_notifier.freezed.dart';

final searchStateNotifierProvider =
    StateNotifierProvider<SearchStateNotifier>((ref) {
  final postRepo = ref.watch(postProvider);
  final settingsRepo = ref.watch(settingsProvider.future);
  final filteredPostRepo = BlackListedFilterDecorator(
      postRepository: postRepo, settingRepository: settingsRepo);
  final removedNullImageRepo =
      NoImageFilterDecorator(postRepository: filteredPostRepo);
  return SearchStateNotifier(ref, removedNullImageRepo);
});

class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier(ProviderReference ref, IPostRepository postRepository)
      : _postRepository = postRepository,
        _ref = ref,
        super(SearchState.initial());

  final IPostRepository _postRepository;
  final ProviderReference _ref;

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
    final posts = <Post>[];
    dtos.forEach((dto) {
      if (dto.file_url != null &&
          dto.preview_file_url != null &&
          dto.large_file_url != null) {
        posts.add(dto.toEntity());
      }
    });

    state = state.copyWith(
      monitoringState: SearchMonitoringState.completed(),
      posts: posts,
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
    final posts = <Post>[];
    dtos.forEach((dto) {
      if (dto.file_url != null &&
          dto.preview_file_url != null &&
          dto.large_file_url != null) {
        posts.add(dto.toEntity());
      }
    });

    state = state.copyWith(
      monitoringState: SearchMonitoringState.completed(),
      posts: [...state.posts, ...posts],
    );
  }

  void clear() {
    state = SearchState.initial();
  }
}
