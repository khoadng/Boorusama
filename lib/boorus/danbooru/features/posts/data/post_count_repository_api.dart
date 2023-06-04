// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/core/boorus/boorus.dart';
import '../models/post_count_repository.dart';

class PostCountRepositoryApi implements PostCountRepository {
  const PostCountRepositoryApi({
    required this.api,
    required this.booruConfig,
    this.extraTags = const [],
  });

  final DanbooruApi api;
  final BooruConfig booruConfig;
  final List<String> extraTags;

  @override
  Future<int?> count(List<String> tags) => api
      .countPosts(
        booruConfig.login,
        booruConfig.apiKey,
        [...tags, ...extraTags].join(' '),
      )
      .then((value) => value.data['counts']['posts'])
      .then((value) => Future<int?>.value(value))
      .catchError((_) => null);
}
