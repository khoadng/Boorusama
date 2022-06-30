// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_create_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_update_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/modal_options.dart';
import 'widgets/comment_item.dart';

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
  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(CommentFetched(postId: widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      CommentCreatePage(postId: widget.postId))),
              child: const Icon(Icons.add),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
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
              return _buildCommentSection(state.comments);
            } else if (state.status == LoadStatus.failure) {
              return const Center(
                child: Text('Something went wrong'),
              );
            } else {
              return Lottie.asset('assets/animations/comment_loading.json');
            }
          },
        ),
      ),
    );
  }

  Widget _buildCommentSection(List<CommentData> comments) {
    if (comments.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
          builder: (context, state) {
            return ListView.builder(
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  title: CommentItem(
                    onVoteChanged: (event) {
                      if (event == VoteEvent.upvoted) {
                        context
                            .read<CommentBloc>()
                            .add(CommentUpvoted(commentId: comment.id));
                      } else if (event == VoteEvent.downvote) {
                        context
                            .read<CommentBloc>()
                            .add(CommentDownvoted(commentId: comment.id));
                      } else if (event == VoteEvent.voteRemoved) {
                        if (comment.hasVote) {
                          context.read<CommentBloc>().add(CommentVoteRemoved(
                                commentId: comment.id,
                                commentVoteId: comment.voteId!,
                                voteState: comment.voteState,
                              ));
                        }
                      } else {
                        //TODO: unknown vote event
                      }
                    },
                    comment: comment,
                    onReply: () => _handleReplyTap(comment, widget.postId),
                    moreBuilder: (context) => state is Authenticated
                        ? _buildMoreButton(comment)
                        : const SizedBox.shrink(),
                  ),
                );
              },
              itemCount: comments.length,
            );
          },
        ),
      );
    } else {
      return Center(
        child: Text('commentListing.notifications.noComments'.tr()),
      );
    }
  }

  Widget _buildMoreButton(CommentData comment) {
    return IconButton(
      onPressed: () => showActionListModalBottomSheet(
        context: context,
        children: [
          if (comment.isSelf)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () => _handleEditTap(comment, widget.postId),
            ),
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.of(context).pop();
              _handleReplyTap(comment, widget.postId);
            },
          ),
          if (comment.isSelf)
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<CommentBloc>().add(CommentDeleted(
                      commentId: comment.id,
                      postId: widget.postId,
                    ));
              },
            ),
        ],
      ),
      icon: const Icon(Icons.more_vert),
    );
  }

  void _handleEditTap(
    CommentData comment,
    int postId,
  ) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentUpdatePage(
          postId: widget.postId,
          commentId: comment.id,
          initialContent: comment.body,
        ),
      ),
    );
  }

  void _handleReplyTap(CommentData comment, int postId) {
    final content =
        '[quote]\n${comment.authorName} said:\n\n${comment.body}\n[/quote]\n\n';

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CommentCreatePage(
              postId: widget.postId,
              initialContent: content,
            )));
  }
}
