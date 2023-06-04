// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/boorus/danbooru/feat/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/feat/comments/comments.dart';
import 'package:boorusama/functional.dart';
import '../models/danbooru_post.dart';
import 'posts_provider.dart';

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();

extension PostDetailsPostX on DanbooruPost {
  void loadDetailsFrom(WidgetRef ref) {
    ref.read(danbooruPostDetailsChildrenProvider(this.id).notifier).load(this);
    ref.read(danbooruPostDetailsArtistProvider(this.id).notifier).load(this);
    ref.read(danbooruPostDetailsCharacterProvider(this.id).notifier).load(this);
    ref.read(danbooruPostDetailsTagsProvider(this.id).notifier).load(this);
    ref.read(danbooruPostDetailsPoolsProvider(this.id).notifier).load();
    ref.read(danbooruCommentsProvider.notifier).load(this.id);
    ref.read(danbooruArtistCommentariesProvider.notifier).load(this.id);
  }
}
