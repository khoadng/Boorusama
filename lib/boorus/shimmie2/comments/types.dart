// Project imports:
import '../../../core/comments/types.dart';
import '../posts/types.dart';
import 'parser.dart';

class Shimmie2CommentExtractor implements CommentExtractor<Shimmie2Post> {
  const Shimmie2CommentExtractor();

  @override
  CommentExtractionResult extractComments(Shimmie2Post source) {
    return switch (source) {
      Shimmie2Post(comments: final comments?) => CommentExtractionSuccess(
        comments.map(commentDtoToComment).nonNulls.toList(),
      ),
      _ => const CommentExtractionNotSupported(),
    };
  }
}
