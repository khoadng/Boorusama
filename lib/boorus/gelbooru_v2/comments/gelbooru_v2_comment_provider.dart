// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../gelbooru_v2.dart';
import 'comments.dart';

final gelbooruV2CommentRepoProvider =
    Provider.family<GelbooruV2CommentRepository, BooruConfigAuth>(
  (ref, config) => GelbooruV2CommentRepositoryApi(
    client: ref.watch(gelbooruV2ClientProvider(config)),
    booruConfig: config,
  ),
);
