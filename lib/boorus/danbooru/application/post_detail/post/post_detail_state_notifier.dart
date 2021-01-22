import 'package:boorusama/boorus/danbooru/domain/posts/post_statistics.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_statistics_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_statistics_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_detail_state.dart';
part 'post_detail_state_notifier.freezed.dart';

class PostDetailStateNotifier extends StateNotifier<PostDetailState> {
  final IPostStatisticsRepository _postStatisticsRepository;

  PostDetailStateNotifier(ProviderReference ref)
      : _postStatisticsRepository = ref.read(postStatisticsProvider),
        super(PostDetailState.initial());

  void getPostStatistics(int id) async {
    try {
      state = PostDetailState.loading();

      final statistics = await _postStatisticsRepository.getPostStatistics(id);

      state = PostDetailState.fetched(statistics: statistics);
    } on Exception {
      state =
          PostDetailState.error(name: "Error", message: "Something went wrong");
    }
  }
}
