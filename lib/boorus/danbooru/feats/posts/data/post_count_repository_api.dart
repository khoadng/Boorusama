// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import '../models/post_count_repository.dart';

class PostCountRepositoryApi implements PostCountRepository {
  const PostCountRepositoryApi({
    required this.api,
    this.extraTags = const [],
  });

  final DanbooruApi api;
  final List<String> extraTags;

  @override
  Future<int?> count(List<String> tags) => api
      .countPosts(
        [...tags, ...extraTags].join(' '),
      )
      .then((value) => value.data['counts']['posts'])
      .then((value) => Future<int?>.value(value))
      .catchError((_) => null);
}
