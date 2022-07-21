// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late final textEditingController = TextEditingController(text: '');
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
        textEditingController.clear();
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
    textEditingController.dispose();
    _focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (isEditing.value) {
          isEditing.value = false;
          return Future.value(false);
        } else {
          return Future.value(true);
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
                            child: _buildCommentSection(
                              state.comments,
                              auth,
                            ),
                          ),
                          if (auth is Authenticated)
                            ValueListenableBuilder(
                              valueListenable: _commentReply,
                              builder: (_, CommentData? value, __) =>
                                  _buildCommentTextField(value),
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

  Widget _buildCommentSection(
    List<CommentData> comments,
    AuthenticationState state,
  ) {
    if (comments.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.builder(
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              title: CommentItem(
                hasVoteSection: state is Authenticated,
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
        ),
      );
    } else {
      return Center(
        child: Text('comment.list.noComments'.tr()),
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
              title: const Text('comment.list.edit').tr(),
              onTap: () => _handleEditTap(comment, widget.postId),
            ),
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('comment.list.reply').tr(),
            onTap: () {
              Navigator.of(context).pop();
              _handleReplyTap(comment, widget.postId);
            },
          ),
          if (comment.isSelf)
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('comment.list.delete').tr(),
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

  Widget _buildCommentTextField(CommentData? comment) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comment != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                children: [
                  Text(
                    '${'comment.list.reply_to'.tr()} ',
                    softWrap: true,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '@${comment.authorName}',
                    softWrap: true,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          TextField(
            focusNode: _focus,
            controller: textEditingController,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.only(bottom: 4),
              hintText: 'comment.create.hint'.tr(),
              border: const UnderlineInputBorder(),
              suffix: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.fullscreen),
                onPressed: () {
                  _handleFullscreenTap(textEditingController.text);
                  isEditing.value = false;
                },
              ),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isEditing,
            builder: (context, value, child) =>
                value ? child! : const SizedBox.shrink(),
            child: Align(
              alignment: Alignment.topRight,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: textEditingController,
                builder: (context, value, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: value.text.isEmpty
                        ? null
                        : () => _handleSendTap(value.text),
                    child: const Text('comment.list.send').tr(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
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
    // final content =
    //     '[quote]\n${comment.authorName} said:\n\n${comment.body}\n[/quote]\n\n';

    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => CommentCreatePage(
    //           postId: widget.postId,
    //           initialContent: content,
    //         )));

    _commentReply.value = comment;
    Future.delayed(const Duration(milliseconds: 100), () {
      _focus.requestFocus();
    });
  }

  void _handleFullscreenTap(String content) {
    String initialContent = content;
    if (_commentReply.value != null) {
      initialContent =
          '[quote]\n${_commentReply.value!.authorName} said:\n\n${_commentReply.value!.body}\n[/quote]\n\n$content';
    }

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CommentCreatePage(
              postId: widget.postId,
              initialContent: initialContent,
            )));
  }

  void _handleSendTap(String content) {
    String initialContent = content;
    if (_commentReply.value != null) {
      initialContent =
          '[quote]\n${_commentReply.value!.authorName} said:\n\n${_commentReply.value!.body}\n[/quote]\n\n$content';
    }

    isEditing.value = false;
    context
        .read<CommentBloc>()
        .add(CommentSent(content: initialContent, postId: widget.postId));
  }
}
