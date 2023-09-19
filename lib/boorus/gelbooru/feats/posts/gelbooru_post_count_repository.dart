// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';

class GelbooruPostCountRepositoryApi implements PostCountRepository {
  const GelbooruPostCountRepositoryApi({
    required this.client,
    required this.booruConfig,
    this.extraTags = const [],
  });

  final GelbooruClient client;
  final BooruConfig booruConfig;
  final List<String> extraTags;

  @override
  Future<int?> count(List<String> tags) => client.countPosts(
        tags: [
          ...tags,
          ...extraTags,
        ],
      ).catchError((e) => null);
}
