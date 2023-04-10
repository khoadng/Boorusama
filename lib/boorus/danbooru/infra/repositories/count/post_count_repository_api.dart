// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';

class PostCountRepositoryApi implements PostCountRepository {
  const PostCountRepositoryApi({
    required this.api,
    required this.currentBooruConfigRepository,
  });

  final DanbooruApi api;
  final CurrentBooruConfigRepository currentBooruConfigRepository;

  @override
  Future<int?> count(List<String> tags) => currentBooruConfigRepository
      .get()
      .then((booruConfig) => api.countPosts(
            booruConfig?.login,
            booruConfig?.apiKey,
            tags.join(' '),
          ))
      .then((value) => value.data['counts']['posts'])
      .then((value) => Future<int?>.value(value))
      .catchError((_) => null);
}
