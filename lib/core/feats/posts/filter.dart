// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';

List<T> filterTags<T extends Post>(List<T> posts, Set<String> tags) =>
    filter({}, {}, posts, tags).data;

({List<T> data, List<T> filtered}) filter<T extends Post>(
  Set<int> currentFilteredIds,
  Set<int> currentNonFilteredIds,
  Iterable<T> posts,
  Iterable<String> blacklistedTags,
) {
  final filtered = <T>[];
  final nonFiltered = <T>[];

  for (final post in posts) {
    if (currentFilteredIds.contains(post.id)) {
      filtered.add(post);
      continue;
    }

    if (currentNonFilteredIds.contains(post.id)) {
      nonFiltered.add(post);
      continue;
    }

    var found = false;
    for (final tag in blacklistedTags) {
      if (post.containsTagPattern(tag)) {
        found = true;
        break;
      }
    }
    if (found) {
      filtered.add(post);
      currentFilteredIds.add(post.id);
    } else {
      nonFiltered.add(post);
      currentNonFilteredIds.add(post.id);
    }
  }

  return (data: nonFiltered, filtered: filtered);
}
