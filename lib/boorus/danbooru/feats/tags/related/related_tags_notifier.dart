// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

class RelatedTagsNotifier
    extends FamilyNotifier<IMap<String, RelatedTag>, BooruConfig> {
  @override
  IMap<String, RelatedTag> build(BooruConfig arg) {
    return <String, RelatedTag>{}.lock;
  }

  RelatedTagRepository get repo => ref.read(danbooruRelatedTagRepProvider(arg));

  Future<void> fetch(String tag) async {
    if (tag.isEmpty) return;
    if (state.containsKey(tag)) return;

    final result = await repo.getRelatedTag(tag);

    state = state.add(tag, result);
  }
}
