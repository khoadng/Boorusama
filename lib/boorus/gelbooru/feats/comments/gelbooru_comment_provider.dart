// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';

final gelbooruCommentRepoProvider = Provider<GelbooruCommentRepository>(
  (ref) => GelbooruCommentRepositoryApi(
    client: ref.watch(gelbooruClientProvider),
    booruConfig: ref.watch(currentBooruConfigProvider),
  ),
);
