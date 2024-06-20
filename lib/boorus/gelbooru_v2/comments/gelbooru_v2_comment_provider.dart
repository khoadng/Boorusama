// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru_v2/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/core/configs/configs.dart';

final gelbooruV2CommentRepoProvider =
    Provider.family<GelbooruV2CommentRepository, BooruConfig>(
  (ref, config) => GelbooruV2CommentRepositoryApi(
    client: ref.watch(gelbooruV2ClientProvider(config)),
    booruConfig: ref.watchConfig,
  ),
);
