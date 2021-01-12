import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_dto.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_detail_state.dart';
part 'post_detail_state_notifier.freezed.dart';

final postDetailStateNotifierProvider =
    StateNotifierProvider<PostDetailStateNotifier>(
        (ref) => PostDetailStateNotifier(ref));

class PostDetailStateNotifier extends StateNotifier<PostDetailState> {
  final IPostRepository _postRepository;

  PostDetailStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        super(PostDetailState.initial());

  void getPost(int id) async {
    try {
      state = PostDetailState.loading();

      final dto = await _postRepository.getPost(id);

      state = PostDetailState.fetched(post: dto.toEntity());
    } on Exception {
      state =
          PostDetailState.error(name: "Error", message: "Something went wrong");
    }
  }
}
