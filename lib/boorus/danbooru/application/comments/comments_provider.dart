// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';

final danbooruCommentRepoProvider = Provider<CommentRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return CommentRepositoryApi(api, booruConfig);
});

final danbooruCommentsProvider =
    NotifierProvider<CommentsNotifier, Map<int, List<CommentData>?>>(
  CommentsNotifier.new,
  dependencies: [
    booruUserIdentityProviderProvider,
    currentBooruConfigProvider,
  ],
);
