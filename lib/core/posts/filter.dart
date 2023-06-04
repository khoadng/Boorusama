// Project imports:
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
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

List<T> filterTags<T extends Post>(List<T> posts, Set<String> tags) => posts
    .where((post) => !tags.intersection(post.tags.toSet()).isNotEmpty)
    .toList();
