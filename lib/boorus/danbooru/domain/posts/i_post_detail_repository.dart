// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post_detail.dart';

abstract class IPostDetailRepository {
  Future<PostDetail> getDetails(int postId);
}
