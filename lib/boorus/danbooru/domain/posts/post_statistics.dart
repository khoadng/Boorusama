import 'package:meta/meta.dart';

class PostStatistics {
  final int favCount;
  final int commentCount;
  final bool isFavorited;

  PostStatistics({
    @required this.favCount,
    @required this.commentCount,
    @required this.isFavorited,
  });
}
