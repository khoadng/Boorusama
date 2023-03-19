// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

abstract class PostFetcher {
  Future<List<DanbooruPost>> fetch(
    DanbooruPostRepository repo,
    int page, {
    int? limit,
  });
}
