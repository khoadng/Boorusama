// Project imports:
import 'artist_commentary_dto.dart';

abstract class IArtistCommentaryRepository {
  Future<ArtistCommentaryDto> getCommentary(int postId);
}
