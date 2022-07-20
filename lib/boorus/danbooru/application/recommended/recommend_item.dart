// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class Recommended {
  Recommended({
    required this.title,
    required this.posts,
    required this.tag,
  });

  final String tag;
  final String title;
  final List<Post> posts;
}
