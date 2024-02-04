// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/uploads/danbooru_upload.dart';
import 'package:boorusama/core/feats/boorus/booru_config.dart';

final danbooruUploadRepoProvider =
    Provider.family<DanbooruUploadRepository, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return DanbooruUploadRepository(client: client);
});
