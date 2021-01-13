import 'package:boorusama/application/post_detail/post/post_view_model.dart';
import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/posts/post_name_generator.dart';

part 'post_detail_state.dart';
part 'post_detail_state_notifier.freezed.dart';

class PostDetailStateNotifier extends StateNotifier<PostDetailState> {
  final IPostRepository _postRepository;
  final PostNameGenerator _postNameGenerator;

  PostDetailStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _postNameGenerator = ref.read(postNameGeneratorProvider),
        super(PostDetailState.initial());

  void getPost(int id) async {
    try {
      state = PostDetailState.loading();

      final dto = await _postRepository.getPost(id);
      final post = dto.toEntity();

      final url = post.isVideo
          ? post.normalImageUri.toString()
          : post.fullImageUri.toString();

      final postVm = PostViewModel(
        id: post.id,
        isTranslated: post.isTranslated,
        isVideo: post.isVideo,
        tagString: post.tagString,
        lowResSource: post.previewImageUri.toString(),
        mediumResSource: post.normalImageUri.toString(),
        highResSource: post.fullImageUri.toString(),
        aspectRatio: post.aspectRatio,
        descriptiveName: _postNameGenerator.generateFor(post, url),
        downloadLink: url,
        characters: post.name.characterOnly.pretty.capitalizeFirstofEach,
        copyrights: post.name.copyRightOnly.pretty.capitalizeFirstofEach,
        favCount: post.favCount,
        height: post.height,
        width: post.width,
      );

      state = PostDetailState.fetched(post: postVm);
    } on Exception {
      state =
          PostDetailState.error(name: "Error", message: "Something went wrong");
    }
  }
}
