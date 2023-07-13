// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/functional.dart';

class RelatedTagsNotifier extends Notifier<IMap<String, RelatedTag>> {
  @override
  IMap<String, RelatedTag> build() {
    return <String, RelatedTag>{}.lock;
  }

  RelatedTagRepository get repo => ref.read(danbooruRelatedTagRepProvider);

  Future<void> fetch(String tag) async {
    if (state.containsKey(tag)) return;

    final result = await repo.getRelatedTag(tag);

    state = state.add(tag, result);
  }
}
