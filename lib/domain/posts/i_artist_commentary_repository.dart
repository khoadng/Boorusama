import 'package:boorusama/domain/posts/artist_commentary.dart';

abstract class IArtistCommentaryRepository {
  Future<ArtistCommentary> getCommentary(int postId);
}
