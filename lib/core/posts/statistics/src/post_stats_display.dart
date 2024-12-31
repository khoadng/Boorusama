// Project imports:
import 'post_stats.dart';

extension PostStatsDisplay on PostStats {
  String get generalRatingPercentageDisplay =>
      '${(generalRatingPercentage * 100).toStringAsFixed(1)}%';
  String get sensitiveRatingPercentageDisplay =>
      '${(sensitiveRatingPercentage * 100).toStringAsFixed(1)}%';
  String get questionableRatingPercentageDisplay =>
      '${(questionableRatingPercentage * 100).toStringAsFixed(1)}%';
  String get explicitRatingPercentageDisplay =>
      '${(explicitRatingPercentage * 100).toStringAsFixed(1)}%';
}
