// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import '../votes/comment_votes_notifier.dart';
import 'comment_data.dart';
import 'comments_notifier.dart';
import 'internal_widgets/comment_box.dart';
import 'internal_widgets/comment_list.dart';

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
        .read(danbooruCommentsProvider(ref.readConfigAuth).notifier)
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

  void _pop() {
    if (isEditing.value) {
      isEditing.value = false;
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final comments = ref.watch(danbooruCommentsProvider(config))[widget.postId];

    return ValueListenableBuilder(
      valueListenable: isEditing,
      builder: (context, edit, child) {
        return PopScope(
          canPop: !edit,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _pop();
          },
          child: child!,
        );
      },
      child: Scaffold(
        appBar: widget.useAppBar
            ? AppBar(
                title: const Text('comment.comments').tr(),
              )
            : null,
        body: SafeArea(
          child: comments.toOption().fold(
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
                              .read(
                                  danbooruCommentVotesProvider(config).notifier)
                              .guardUpvote(ref, comment.id),
                          onDownvote: (comment) => ref
                              .read(
                                  danbooruCommentVotesProvider(config).notifier)
                              .guardDownvote(ref, comment.id),
                          onClearVote: (comment, commentVote) => ref
                              .read(
                                  danbooruCommentVotesProvider(config).notifier)
                              .guardUnvote(ref, commentVote),
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
      ),
    );
  }
}
