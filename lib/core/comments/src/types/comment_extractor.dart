// Project imports:
import 'comment.dart';

sealed class CommentExtractionResult {
  const CommentExtractionResult();
}

final class CommentExtractionSuccess extends CommentExtractionResult {
  const CommentExtractionSuccess(this.comments);
  final List<Comment> comments;
}

final class CommentExtractionNotSupported extends CommentExtractionResult {
  const CommentExtractionNotSupported();
}

abstract class CommentExtractor<T> {
  CommentExtractionResult extractComments(T source);
}

class UnsupportedCommentExtractor implements CommentExtractor<Object?> {
  const UnsupportedCommentExtractor();

  @override
  CommentExtractionResult extractComments(Object? source) {
    return const CommentExtractionNotSupported();
  }
}
