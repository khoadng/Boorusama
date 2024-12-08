// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/core/configs/config.dart';

final gelbooruCommentRepoProvider =
    Provider.family<GelbooruCommentRepository, BooruConfigAuth>(
  (ref, config) => GelbooruCommentRepositoryApi(
    client: ref.watch(gelbooruClientProvider(config)),
    booruConfig: config,
  ),
);
