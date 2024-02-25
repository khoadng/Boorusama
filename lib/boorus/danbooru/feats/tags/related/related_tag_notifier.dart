// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';

class DanbooruRelatedTagNotifier extends AutoDisposeAsyncNotifier<RelatedTag> {
  @override
  RelatedTag build() {
    return const RelatedTag.empty();
  }

  Future<void> getRelatedTag(String tag) async {
    final arg = ref.readConfig;
    state = const AsyncLoading();

    final repo = ref.watch(danbooruRelatedTagRepProvider(arg));
    final relatedTag = await repo.getRelatedTag(tag);

    state = AsyncData(relatedTag);
  }
}
