// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/boorus/providers.dart';
import 'package:boorusama/boorus/danbooru/features/wikis/wikis.dart';

class WikisNotifier extends Notifier<Map<String, Wiki?>> {
  @override
  Map<String, Wiki?> build() {
    ref.watch(currentBooruConfigProvider);
    return {};
  }

  Future<void> fetchWikiFor(String tag) async {
    if (state.containsKey(tag)) return;

    final wiki = await ref.read(danbooruWikiRepoProvider).getWikiFor(tag);
    if (wiki != null) {
      state = {
        ...state,
        tag: wiki,
      };
    }
  }
}
