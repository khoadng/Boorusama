// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_statistics.dart';

class PostDetail {
  final ArtistCommentary artistCommentary;
  final PostStatistics postStatistics;

  PostDetail({
    @required this.artistCommentary,
    @required this.postStatistics,
  });

  factory PostDetail.empty() => PostDetail(
        artistCommentary: ArtistCommentary.empty(),
        postStatistics: PostStatistics.empty(),
      );
}
