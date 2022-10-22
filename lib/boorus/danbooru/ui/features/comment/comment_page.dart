// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_update_page.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'widgets/widgets.dart';

Future<T?> showCommentPage<T>(
  BuildContext context, {
  required int postId,
}) =>
    Screen.of(context).size == ScreenSize.small
        ? showBarModalBottomSheet<T>(
            context: context,
            builder: (context) => CommentPage(
              postId: postId,
            ),
          )
        : showSideSheetFromRight(
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
                      color: Theme.of(context).backgroundColor,
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
                          style: Theme.of(context).textTheme.headline6,
                        ).tr(),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            onTap: Navigator.of(context).pop,
                            child: const Icon(Icons.close),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CommentPage(
                      useAppBar: false,
                      postId: postId,
                    ),
                  ),
                ],
              ),
            ),
            context: context,
          );

class CommentPage extends StatefulWidget {
  const CommentPage({
    super.key,
    required this.postId,
    this.useAppBar = true,
  });

  final int postId;
  final bool useAppBar;

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late final FocusNode _focus = FocusNode();
  final _commentReply = ValueNotifier<CommentData?>(null);
  final isEditing = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(CommentFetched(postId: widget.postId));

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
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            : null,
        body: BlocBuilder<CommentBloc, CommentState>(
          builder: (context, state) {
            if (state.status == LoadStatus.success) {
              return GestureDetector(
                onTap: () => isEditing.value = false,
                child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
                  builder: (context, auth) {
                    return Column(
                      children: [
                        Expanded(
                          child: CommentList(
                            comments: state.comments,
                            authenticated: auth is Authenticated,
                            onEdit: (comment) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CommentUpdatePage(
                                    postId: widget.postId,
                                    commentId: comment.id,
                                    initialContent: comment.body,
                                  ),
                                ),
                              );
                            },
                            onReply: (comment) {
                              _commentReply.value = comment;
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                _focus.requestFocus,
                              );
                            },
                            onDelete: (comment) =>
                                context.read<CommentBloc>().add(CommentDeleted(
                                      commentId: comment.id,
                                      postId: widget.postId,
                                    )),
                            onUpvote: (comment) => context
                                .read<CommentBloc>()
                                .add(CommentUpvoted(commentId: comment.id)),
                            onDownvote: (comment) => context
                                .read<CommentBloc>()
                                .add(CommentDownvoted(commentId: comment.id)),
                            onClearVote: (comment) => context
                                .read<CommentBloc>()
                                .add(CommentVoteRemoved(
                                  commentId: comment.id,
                                  commentVoteId: comment.voteId!,
                                  voteState: comment.voteState,
                                )),
                          ),
                        ),
                        if (auth is Authenticated)
                          CommentBox(
                            focus: _focus,
                            commentReply: _commentReply,
                            postId: widget.postId,
                            isEditing: isEditing,
                          ),
                      ],
                    );
                  },
                ),
              );
            } else if (state.status == LoadStatus.failure) {
              return const Center(
                child: Text('Something went wrong'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          },
        ),
      ),
    );
  }
}
