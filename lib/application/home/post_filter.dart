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
