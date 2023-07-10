// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/functional.dart';

TaskEither<BooruError, List<T>> tryFilterBlacklisted<T extends Post>(
  List<T> posts,
  GlobalBlacklistedTagRepository repository,
) =>
    TaskEither(() => getBlacklistedTags(repository)
        .then((blacklisted) => Either.of(filterTags(posts, blacklisted))));

mixin GlobalBlacklistedTagFilterMixin {
  GlobalBlacklistedTagRepository get blacklistedTagRepository;

  TaskEither<BooruError, List<T>> tryFilterBlacklistedTags<T extends Post>(
    List<T> posts,
  ) =>
      tryFilterBlacklisted(posts, blacklistedTagRepository);
}

List<T> filterTags<T extends Post>(List<T> posts, Set<String> tags) =>
    filter(posts, tags).data;

({List<T> data, List<T> filtered}) filter<T extends Post>(
  List<T> posts,
  Iterable<String> blacklistedTags,
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
