// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru_v2/comments/comments.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';

class GelbooruV2CommentPage extends ConsumerWidget {
  const GelbooruV2CommentPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    return CommentPageScaffold(
      postId: postId,
      fetcher: (postId) =>
          ref.watch(gelbooruV2CommentRepoProvider(config)).getComments(postId),
    );
  }
}
