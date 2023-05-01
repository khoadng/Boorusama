// Project imports:
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/functional.dart';

TaskEither<BooruError, List<Post>> tryFilterBlacklisted(
  List<Post> posts,
  BlacklistedTagRepository repository,
) =>
    TaskEither(() => getBlacklistedTags(repository)
        .then((blacklisted) => Either.of(filterTags(posts, blacklisted))));

mixin BlacklistedTagFilterMixin {
  BlacklistedTagRepository get blacklistedTagRepository;

  TaskEither<BooruError, List<Post>> tryFilterBlacklistedTags(
    List<Post> posts,
  ) =>
      tryFilterBlacklisted(posts, blacklistedTagRepository);
}

List<Post> filterTags(List<Post> posts, Set<String> tags) => posts
    .where((post) => !tags.intersection(post.tags.toSet()).isNotEmpty)
    .toList();
