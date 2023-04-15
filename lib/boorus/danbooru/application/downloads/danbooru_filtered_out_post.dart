// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/downloads/filtered_out_post.dart';

enum FilteredReason {
  bannedArtist,
  censoredTag,
  unknown,
}

class DanbooruFilteredOutPost extends FilteredOutPost {
  DanbooruFilteredOutPost({
    required DanbooruPost post,
  }) : super(
          postId: post.id,
          reason: post.isBanned
              ? FilteredReason.bannedArtist.name
              : post.hasCensoredTags
                  ? FilteredReason.censoredTag.name
                  : FilteredReason.unknown.name,
        );
}
