// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/posts/posts.dart';
import 'package:boorusama/boorus/core/tags/tags.dart';
import '../models/danbooru_post.dart';

class PostDetailsTagsNotifier
    extends AutoDisposeFamilyNotifier<List<PostDetailTag>, int> {
  @override
  List<PostDetailTag> build(int arg) {
    return [];
  }

  Future<void> load(DanbooruPost p) async {
    state = _buildTags(p);
  }

  List<PostDetailTag> _buildTags(DanbooruPost p) {
    return [
      ...p.artistTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.artist.stringify(),
            postId: p.id,
          )),
      ...p.characterTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.charater.stringify(),
            postId: p.id,
          )),
      ...p.copyrightTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.copyright.stringify(),
            postId: p.id,
          )),
      ...p.generalTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.general.stringify(),
            postId: p.id,
          )),
      ...p.metaTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.meta.stringify(),
            postId: p.id,
          )),
    ];
  }
}
