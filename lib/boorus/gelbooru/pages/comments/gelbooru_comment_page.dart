// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/gelbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/pages/comments/gelbooru_comment_item.dart';
import 'package:boorusama/foundation/i18n.dart';

class GelbooruCommentPage extends ConsumerWidget {
  const GelbooruCommentPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(gelbooruCommentsProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('comment.comments').tr(),
      ),
      body: comments.when(
        data: (comments) => comments.isNotEmpty
            ? ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GelbooruCommentItem(comment: comments[index]),
                ),
              )
            : const NoDataBox(),
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}
