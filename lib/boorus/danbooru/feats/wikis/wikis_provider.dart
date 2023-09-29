// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/wikis/wikis.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';

final danbooruWikiRepoProvider = Provider<WikiRepository>((ref) {
  return WikiRepositoryApi(ref.watch(danbooruClientProvider));
});

final danbooruWikisProvider =
    NotifierProvider<WikisNotifier, Map<String, Wiki?>>(
  WikisNotifier.new,
  dependencies: [
    danbooruWikiRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruWikiProvider = Provider.family<WikiState, String>((ref, tag) {
  final wikis = ref.watch(danbooruWikisProvider);
  if (wikis.containsKey(tag)) {
    return wikis[tag] == null
        ? const WikiStateNotFound()
        : WikiStateLoaded(wikis[tag]!);
  } else {
    ref.read(danbooruWikisProvider.notifier).fetchWikiFor(tag);
    return const WikiStateLoading();
  }
});
