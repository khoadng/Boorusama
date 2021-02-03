// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments/user.dart';

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
