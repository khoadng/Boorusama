// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';

class RelatedTagsNotifier extends Notifier<Map<String, RelatedTag>> {
  @override
  Map<String, RelatedTag> build() {
    return {};
  }

  RelatedTagRepository get repo => ref.read(danbooruRelatedTagRepProvider);

  Future<void> fetch(String tag) async {
    if (state.containsKey(tag)) return;

    final result = await repo.getRelatedTag(tag);

    state = {
      ...state,
      tag: result,
    };
  }
}
