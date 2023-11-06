// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/comments/comment_box.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/comments/comment_list.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/functional.dart';

class CommentPage extends ConsumerStatefulWidget {
  const CommentPage({
    super.key,
    required this.postId,
    this.useAppBar = true,
  });

  final int postId;
  final bool useAppBar;

  @override
  ConsumerState<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends ConsumerState<CommentPage> {
  late final _focus = FocusNode();
  final _commentReply = ValueNotifier<CommentData?>(null);
  final isEditing = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    ref
        .read(danbooruCommentsProvider(ref.readConfig).notifier)
        .load(widget.postId);

    isEditing.addListener(_onEditing);

    _focus.addListener(() {
      if (_focus.hasPrimaryFocus) {
        isEditing.value = true;
      }
    });
  }

  void _onEditing() {
    if (!isEditing.value) {
      _commentReply.value = null;
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    isEditing.removeListener(_onEditing);
    _focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final comments = ref.watch(danbooruCommentsProvider(config))[widget.postId];

    return WillPopScope(
      onWillPop: () async {
        if (isEditing.value) {
          isEditing.value = false;

          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: widget.useAppBar
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () => context.navigator.pop(),
                ),
              )
            : null,
        body: comments.toOption().fold(
              () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              (comments) => GestureDetector(
                onTap: () => isEditing.value = false,
                child: Column(
                  children: [
                    Expanded(
                      child: CommentList(
                        comments: comments,
                        authenticated: config.hasLoginDetails(),
                        onEdit: (comment) {
                          goToCommentUpdatePage(
                            context,
                            postId: widget.postId,
                            commentId: comment.id,
                            commentBody: comment.body,
                          );
                        },
                        onReply: (comment) async {
                          _commentReply.value = comment;
                          await const Duration(milliseconds: 100).future;
                          _focus.requestFocus();
                        },
                        onDelete: (comment) => ref
                            .read(danbooruCommentsProvider(config).notifier)
                            .delete(postId: widget.postId, comment: comment),
                        onUpvote: (comment) => ref
                            .read(danbooruCommentVotesProvider(config).notifier)
                            .upvote(comment.id),
                        onDownvote: (comment) => ref
                            .read(danbooruCommentVotesProvider(config).notifier)
                            .downvote(comment.id),
                        onClearVote: (comment, commentVote) => ref
                            .read(danbooruCommentVotesProvider(config).notifier)
                            .unvote(commentVote),
                      ),
                    ),
                    if (config.hasLoginDetails())
                      CommentBox(
                        focus: _focus,
                        commentReply: _commentReply,
                        postId: widget.postId,
                        isEditing: isEditing,
                      ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
