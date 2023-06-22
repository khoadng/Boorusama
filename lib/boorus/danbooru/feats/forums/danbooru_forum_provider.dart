import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/functional.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final danbooruForumTopicRepoProvider =
    Provider<DanbooruForumTopicRepository>((ref) {
  return DanbooruForumTopicRepositoryApi(
    api: ref.watch(danbooruApiProvider),
    booruConfig: ref.watch(currentBooruConfigProvider),
  );
});

final danbooruForumTopicsProvider = FutureProvider.autoDispose
    .family<IList<DanbooruForumTopic>, int>((ref, page) async {
  final repo = ref.watch(danbooruForumTopicRepoProvider);
  return repo.getForumTopicsOrEmpty(page);
});
