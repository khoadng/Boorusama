// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';

class GelbooruPostCountRepositoryApi implements PostCountRepository {
  const GelbooruPostCountRepositoryApi({
    required this.api,
    required this.booruConfig,
    this.extraTags = const [],
  });

  final GelbooruApi api;
  final BooruConfig booruConfig;
  final List<String> extraTags;

  @override
  Future<int?> count(List<String> tags) => api
      .getPosts(
        booruConfig.apiKey,
        booruConfig.login,
        'dapi',
        'post',
        'index',
        [
          ...tags,
          ...extraTags,
        ].join(' '),
        '1',
        '0',
      )
      .then((value) => value.data['@attributes']['count'])
      .then((value) => Future<int?>.value(value))
      .catchError((e) => null);
}
