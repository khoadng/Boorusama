// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_update_page.dart';
import 'widgets/widgets.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({
    Key? key,
    required this.postId,
  }) : super(key: key);

  final int postId;

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

    isEditing.addListener(() {
      if (!isEditing.value) {
        _commentReply.value = null;
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
    _focus.addListener(() {
      if (_focus.hasPrimaryFocus) {
        isEditing.value = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<CommentBloc, CommentState>(
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
                                    const Duration(milliseconds: 100), () {
                                  _focus.requestFocus();
                                });
                              },
                              onDelete: (comment) => context
                                  .read<CommentBloc>()
                                  .add(CommentDeleted(
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
      ),
    );
  }
}
