// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../gelbooru.dart';
import 'comments.dart';

final gelbooruCommentRepoProvider =
    Provider.family<GelbooruCommentRepository, BooruConfigAuth>(
  (ref, config) => GelbooruCommentRepositoryApi(
    client: ref.watch(gelbooruClientProvider(config)),
    booruConfig: config,
  ),
);
