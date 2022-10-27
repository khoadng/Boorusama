// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class FilteredOutPost extends Equatable {
  const FilteredOutPost({
    required this.postId,
    required this.reason,
  });

  factory FilteredOutPost.from(Post post) {
    return FilteredOutPost(
      postId: post.id,
      reason: post.isBanned
          ? FilteredReason.bannedArtist
          : post.hasCensoredTags
              ? FilteredReason.censoredTag
              : FilteredReason.unknown,
    );
  }

  final int postId;
  final FilteredReason reason;

  @override
  List<Object?> get props => [postId, reason];
}

enum FilteredReason {
  bannedArtist,
  censoredTag,
  unknown,
}
