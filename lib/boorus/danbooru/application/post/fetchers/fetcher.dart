// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

abstract class PostFetcher {
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  );
}
