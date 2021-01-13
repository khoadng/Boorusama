import 'package:boorusama/application/home/post_view_model.dart';
import 'package:boorusama/domain/posts/post_name_generator.dart';
import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting.dart';

List<Post> filter(List<PostDto> dtos, Setting setting) {
  final posts = <Post>[];
  dtos.forEach((dto) {
    if (dto.file_url != null &&
        dto.preview_file_url != null &&
        dto.large_file_url != null) {
      posts.add(dto.toEntity());
    }
  });

  final filteredPosts = posts
      .where((post) => !post.containsBlacklistedTag(setting.blacklistedTags))
      .toList();
  return filteredPosts;
}

List<PostViewModel> getPostVms(
    List<Post> filteredPosts, PostNameGenerator postNameGenerator) {
  final postVms = <PostViewModel>[];
  filteredPosts.forEach((post) {
    final url = post.isVideo
        ? post.normalImageUri.toString()
        : post.fullImageUri.toString();

    final postVm = PostViewModel(
      id: post.id,
      isTranslated: post.isTranslated,
      isVideo: post.isVideo,
      hasComment: post.hasComment,
      isAnimated: post.isAnimated,
      tagString: post.tagString,
      lowResSource: post.previewImageUri.toString(),
      mediumResSource: post.normalImageUri.toString(),
      highResSource: post.fullImageUri.toString(),
      aspectRatio: post.aspectRatio,
      descriptiveName: postNameGenerator.generateFor(post, url),
      downloadLink: url,
      favCount: post.favCount,
      height: post.height,
      width: post.width,
    );
    postVms.add(postVm);
  });
  return postVms;
}
