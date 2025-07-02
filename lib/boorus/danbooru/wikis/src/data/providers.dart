// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../client_provider.dart';
import '../types/wiki_repository.dart';
import 'wiki_repository_api.dart';

final danbooruWikiRepoProvider =
    Provider.family<WikiRepository, BooruConfigAuth>((ref, config) {
  return WikiRepositoryApi(ref.watch(danbooruClientProvider(config)));
});
