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
  Widget _buildCommentSection(List<CommentData> comments) {
    if (comments.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              onLongPress: () => showActionListModalBottomSheet(
                context: context,
                children: [
                  if (comment.isSelf)
                    const ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      // onTap: () => _handle,
                    ),
                  ListTile(
                    leading: const Icon(Icons.reply),
                    title: const Text('Reply'),
                    onTap: () => _handleReplyTap(comment, widget.postId),
                  ),
                ],
              ),
              title: CommentItem(
                comment: comment,
              ),
            );
          },
          itemCount: comments.length,
        ),
      );
    } else {
      return Center(
        child: Text('commentListing.notifications.noComments'.tr()),
      );
    }
  }

  // void _handleEditTap(BuildContext context, CommentData comment, int postId) async {
  //   Navigator.of(context).pop();
  //   await Navigator.of(context).push(
  //     PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) =>
  //           CommentUpdatePage(
  //         postId: widget.postId,
  //         commentId: comment.id,
  //         initialContent: comment.body,
  //       ),
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
  //           SharedAxisTransition(
  //         child: child,
  //         animation: animation,
  //         secondaryAnimation: secondaryAnimation,
  //         transitionType: SharedAxisTransitionType.scaled,
  //       ),
  //       transitionDuration: const Duration(milliseconds: 500),
  //     ),
  //   );
  // }

  void _handleReplyTap(CommentData comment, int postId) {
    final content =
        '[quote]\n${comment.authorName} said:\n\n${comment.body}\n[/quote]\n\n';

    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CommentCreatePage(
        postId: widget.postId,
        initialContent: content,
      ),
      fullscreenDialog: true,
    ));
  }

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(CommentFetched(postId: widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Scaffold(
            floatingActionButton:
                BlocBuilder<AuthenticationCubit, AuthenticationState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return FloatingActionButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                CommentCreatePage(postId: widget.postId))),
                    child: const Icon(Icons.add),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: BlocBuilder<CommentBloc, CommentState>(
                        builder: (context, state) {
                          if (state.status == LoadStatus.success) {
                            return _buildCommentSection(state.comments);
                          } else if (state.status == LoadStatus.failure) {
                            return const Center(
                              child: Text('Something went wrong'),
                            );
                          } else {
                            return Lottie.asset(
                                'assets/animations/comment_loading.json');
                          }
                        },
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
