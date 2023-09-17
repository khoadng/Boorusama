// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';

class PostCountRepositoryApi implements PostCountRepository {
  const PostCountRepositoryApi({
    required this.client,
    this.extraTags = const [],
  });

  final DanbooruClient client;
  final List<String> extraTags;

  @override
  Future<int?> count(List<String> tags) => client.countPosts(
        tags: [...tags, ...extraTags],
      );
}
