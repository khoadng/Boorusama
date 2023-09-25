// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/boorus/danbooru/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();

extension PostDetailsPostX on DanbooruPost {
  void loadDetailsFrom(WidgetRef ref) {
    ref.read(danbooruCommentsProvider.notifier).load(id);
    ref.read(danbooruArtistCommentariesProvider.notifier).load(id);
  }
}
