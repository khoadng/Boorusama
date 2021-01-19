import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';

abstract class IArtistCommentaryRepository {
  Future<ArtistCommentary> getCommentary(int postId);
}
