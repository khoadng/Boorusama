// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_detail_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_detail.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_detail_repository.dart';

part 'post_detail_state.dart';
part 'post_detail_state_notifier.freezed.dart';

class PostDetailStateNotifier extends StateNotifier<PostDetailState> {
  final IPostDetailRepository _postDetailRepository;

  PostDetailStateNotifier(ProviderReference ref)
      : _postDetailRepository = ref.read(postDetailProvider),
        super(PostDetailState.initial());

  void getDetails(int id) async {
    try {
      state = PostDetailState.loading();

      final details = await _postDetailRepository.getDetails(id);

      state = PostDetailState.fetched(details: details);
    } on Exception {
      state =
          PostDetailState.error(name: "Error", message: "Something went wrong");
    }
  }
}
