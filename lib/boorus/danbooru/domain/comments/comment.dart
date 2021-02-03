// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';

@freezed
abstract class Comment with _$Comment {
  const factory Comment(
      {@required int id,
      @required DateTime createdAt,
      @required int postId,
      @required @nullable int creatorId,
      @required @nullable String body,
      @required int score,
      @required String updatedAt,
      @required @nullable int updaterId,
      @required bool isDeleted}) = _Comment;
}
