// Project imports:
import '../../post/types.dart';
import '../../sources/types.dart';
import 'check_tag.dart';
import 'tag_expression.dart';
import 'tag_filter_data.dart';

List<T> filterTags<T extends Post>(List<T> posts, Set<String> tags) =>
    filter(posts, tags, precomputedFilter: {}).data;

({List<T> data, List<T> filtered}) filter<T extends Post>(
  Iterable<T> posts,
  Set<String> blacklistedTags, {
  required Map<int, bool> precomputedFilter,
}) {
  final filtered = <T>[];
  final nonFiltered = <T>[];
  final preprocessedBlacklist = blacklistedTags
      .map((tag) => tag.split(' ').map(TagExpression.parse).toList())
      .toList();

  for (final post in posts) {
    // Check precomputed filter if there is a post Id, it means it has been checked before, so we can use the result instead of rechecking
    if (precomputedFilter.containsKey(post.id)) {
      if (precomputedFilter[post.id]!) {
        filtered.add(post);
      } else {
        nonFiltered.add(post);
      }
      continue;
    }

    var found = false;
    for (final tag in preprocessedBlacklist) {
      if (post.containsTagPattern(tag)) {
        found = true;
        break;
      }
    }
    if (found) {
      filtered.add(post);
      precomputedFilter[post.id] = true;
    } else {
      nonFiltered.add(post);
      precomputedFilter[post.id] = false;
    }
  }

  return (data: nonFiltered, filtered: filtered);
}

extension PostFilterX on Post {
  TagFilterData extractTagFilterData() => TagFilterData(
    tags: tags.map((tag) => tag.toLowerCase()).toSet(),
    rating: rating,
    score: score,
    downvotes: downvotes,
    uploaderId: uploaderId,
    uploaderName: uploaderName,
    source: switch (source) {
      final WebSource w => w.url,
      final NonWebSource nw => nw.value,
      _ => null,
    }?.toLowerCase(),
    id: id,
    status: status,
  );

  bool containsTagPattern(List<TagExpression> pattern) =>
      checkIfTagsContainsTagExpression(
        extractTagFilterData(),
        pattern,
      );
}
