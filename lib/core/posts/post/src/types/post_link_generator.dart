// Project imports:
import 'post.dart';

abstract class PostLinkGenerator<T extends Post> {
  String getLink(T post);
}
