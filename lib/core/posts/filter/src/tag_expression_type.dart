// Project imports:
import '../../rating/rating.dart';

sealed class TagExpressionType {
  const TagExpressionType(this.value);
  final String value;
}

final class TagType extends TagExpressionType {
  const TagType(super.value);
}

final class RatingType extends TagExpressionType {
  const RatingType(super.value, this.rating);

  final Rating rating;
}

final class UploaderIdType extends TagExpressionType {
  const UploaderIdType(super.value, this.uploaderId);

  final int uploaderId;
}

final class SourceType extends TagExpressionType {
  const SourceType(
    super.value,
    this.source,
    this.wildCardPosition,
  );

  final String source;
  final WildCardPosition wildCardPosition;
}

final class ScoreType extends TagExpressionType {
  const ScoreType(super.value, this.score);

  final int score;
}

final class DownvotesType extends TagExpressionType {
  const DownvotesType(super.value, this.downvotes);

  final int downvotes;
}

enum WildCardPosition {
  start,
  end,
  both,
  none,
}
