// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final gelbooruCommentRepoProvider =
    Provider.family<GelbooruCommentRepository, BooruConfig>(
  (ref, config) => GelbooruCommentRepositoryApi(
    client: ref.watch(gelbooruClientProvider(config)),
    booruConfig: ref.watchConfig,
  ),
);
