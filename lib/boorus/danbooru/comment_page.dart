// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'router.dart';
import 'widgets/comments/comment_box.dart';
import 'widgets/comments/comment_list.dart';

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
    ref.read(danbooruCommentsProvider.notifier).load(widget.postId);

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
    final comments = ref.watch(danbooruCommentsProvider)[widget.postId];
    final auth = ref.watch(authenticationProvider);

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
              () => const SizedBox.shrink(),
              (comments) => GestureDetector(
                onTap: () => isEditing.value = false,
                child: Column(
                  children: [
                    Expanded(
                      child: CommentList(
                        comments: comments,
                        authenticated: auth.isAuthenticated,
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
                            .read(danbooruCommentsProvider.notifier)
                            .delete(postId: widget.postId, comment: comment),
                        onUpvote: (comment) => ref
                            .read(danbooruCommentVotesProvider.notifier)
                            .upvote(comment.id),
                        onDownvote: (comment) => ref
                            .read(danbooruCommentVotesProvider.notifier)
                            .downvote(comment.id),
                        onClearVote: (comment, commentVote) => ref
                            .read(danbooruCommentVotesProvider.notifier)
                            .unvote(commentVote),
                      ),
                    ),
                    if (auth.isAuthenticated)
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

Future<T?> showCommentPage<T>(
  BuildContext context, {
  required int postId,
  RouteSettings? settings,
  required Widget Function(BuildContext context, bool useAppBar) builder,
}) =>
    Screen.of(context).size == ScreenSize.small
        ? showMaterialModalBottomSheet<T>(
            context: context,
            settings: settings,
            duration: const Duration(milliseconds: 250),
            builder: (context) => builder(context, true),
          )
        : showSideSheetFromRight(
            settings: settings,
            width: MediaQuery.of(context).size.width * 0.41,
            body: Container(
              color: Colors.transparent,
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
              child: Column(
                children: [
                  Container(
                    height: kToolbarHeight * 0.8,
                    decoration: BoxDecoration(
                      color: context.colorScheme.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'comment.comments',
                          style: context.textTheme.titleLarge,
                        ).tr(),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            onTap: context.navigator.pop,
                            child: const Icon(Icons.close),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: builder(context, false),
                  ),
                ],
              ),
            ),
            context: context,
          );
