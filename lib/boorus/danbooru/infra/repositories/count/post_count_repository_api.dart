// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';

class PostCountRepositoryApi implements PostCountRepository {
  const PostCountRepositoryApi({
    required this.api,
    required this.currentUserBooruRepository,
  });

  final DanbooruApi api;
  final CurrentUserBooruRepository currentUserBooruRepository;

  @override
  Future<int?> count(List<String> tags) => currentUserBooruRepository
      .get()
      .then((userBooru) => api.countPosts(
            userBooru?.login,
            userBooru?.apiKey,
            tags.join(' '),
          ))
      .then((value) => value.data['counts']['posts'])
      .then((value) => Future<int?>.value(value))
      .catchError((_) => null);
}
