// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';

List<T> filterTags<T extends Post>(List<T> posts, Set<String> tags) =>
    filter(posts, tags).data;

({List<T> data, List<T> filtered}) filter<T extends Post>(
  Iterable<T> posts,
  Set<String> blacklistedTags,
) {
  final filtered = <T>[];
  final nonFiltered = <T>[];

  for (final post in posts) {
    var found = false;
    for (final tag in blacklistedTags) {
      if (post.containsTagPattern(tag)) {
        found = true;
        break;
      }
    }
    if (found) {
      filtered.add(post);
    } else {
      nonFiltered.add(post);
    }
  }

  return (data: nonFiltered, filtered: filtered);
}
