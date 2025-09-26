import 'package:flutter/widgets.dart';

import '../../../../../boorus/danbooru/posts/listing/providers.dart';
import '../../../../../boorus/danbooru/posts/post/post.dart';
import '../../../../../boorus/danbooru/posts/votes/providers.dart';
import '../../../../posts/favorites/widgets.dart';
import 'booru_intents.dart';
import 'generic_intents.dart';

class EditPostAction extends Action<EditPostIntent> {
  @override
  Object? invoke(EditPostIntent intent) {
    if (intent.post case final DanbooruPost danbooruPost) {
      intent.ref.danbooruEdit(danbooruPost);
    }
    return null;
  }
}

class UpvotePostAction extends Action<UpvotePostIntent> {
  @override
  Object? invoke(UpvotePostIntent intent) {
    if (intent.post case final DanbooruPost danbooruPost) {
      intent.ref.danbooruUpvote(danbooruPost.id);
    }
    return null;
  }
}

class DownvotePostAction extends Action<DownvotePostIntent> {
  @override
  Object? invoke(DownvotePostIntent intent) {
    if (intent.post case final DanbooruPost danbooruPost) {
      intent.ref.danbooruDownvote(danbooruPost.id);
    }
    return null;
  }
}

class FavoritePostAction extends Action<FavoritePostIntent> {
  @override
  Object? invoke(FavoritePostIntent intent) {
    intent.ref.toggleFavorite(intent.post.id);
    return null;
  }
}
