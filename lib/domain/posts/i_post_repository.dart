import 'package:boorusama/domain/posts/post.dart';

abstract class IPostRepository {
  Future<List<Post>> getPosts(String tagString, int page);
}
