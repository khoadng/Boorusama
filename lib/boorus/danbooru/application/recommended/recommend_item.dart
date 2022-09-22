// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';

class Recommended {
  Recommended({
    required this.title,
    required this.posts,
    required this.tag,
  });

  final String tag;
  final String title;
  final List<PostData> posts;
}
