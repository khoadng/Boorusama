import 'package:boorusama/boorus/danbooru/application/comment/user.dart';
import 'package:meta/meta.dart';

class Comment {
  final int id;
  final User author;
  final String content;
  final bool isDeleted;
  final DateTime createdAt;

  Comment({
    @required this.id,
    @required this.author,
    @required this.content,
    @required this.isDeleted,
    @required this.createdAt,
  });
}
