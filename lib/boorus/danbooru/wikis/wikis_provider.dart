// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/wikis/wikis.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';

final danbooruWikiRepoProvider =
    Provider.family<WikiRepository, BooruConfig>((ref, config) {
  return WikiRepositoryApi(ref.watch(danbooruClientProvider(config)));
});

final danbooruWikisProvider =
    NotifierProvider.family<WikisNotifier, Map<String, Wiki?>, BooruConfig>(
  WikisNotifier.new,
  dependencies: [
    danbooruWikiRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruWikiProvider = Provider.family<WikiState, String>((ref, tag) {
  final config = ref.watchConfig;
  final wikis = ref.watch(danbooruWikisProvider(config));
  if (wikis.containsKey(tag)) {
    return wikis[tag] == null
        ? const WikiStateNotFound()
        : WikiStateLoaded(wikis[tag]!);
  } else {
    ref.read(danbooruWikisProvider(config).notifier).fetchWikiFor(tag);
    return const WikiStateLoading();
  }
});
