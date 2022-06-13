// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

List<Post> filter(List<Post> posts, List<String> blacklistedTags) {
  final tagMap = Map.fromIterable(blacklistedTags);
  return posts
      .where((p) => !p.tags.any((element) => tagMap.containsKey(element)))
      .toList();
}
