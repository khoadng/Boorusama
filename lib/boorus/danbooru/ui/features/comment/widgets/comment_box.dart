// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'reply_header.dart';

class CommentBox extends StatefulWidget {
  const CommentBox({
    super.key,
    required this.commentReply,
    required this.isEditing,
    required this.postId,
    required this.focus,
  });

  final ValueNotifier<CommentData?> commentReply;
  final ValueNotifier<bool> isEditing;
  final int postId;
  final FocusNode focus;

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  late final textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    widget.isEditing.addListener(_onEditing);
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
    widget.isEditing.removeListener(_onEditing);
  }

  void _onEditing() {
    if (!widget.isEditing.value) {
      textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CommentData?>(
      valueListenable: widget.commentReply,
      builder: (_, comment, __) => Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (comment != null) ReplyHeader(comment: comment),
            TextField(
              focusNode: widget.focus,
              controller: textEditingController,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'comment.create.hint'.tr(),
                border: const UnderlineInputBorder(),
                suffix: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    final content = textEditingController.text;
                    String initialContent = content;
                    if (comment != null) {
                      initialContent =
                          '[quote]\n${comment.authorName} said:\n\n${comment.body}\n[/quote]\n\n$content';
                    }

                    goToCommentCreatePage(
                      context,
                      postId: widget.postId,
                      initialContent: initialContent,
                    );
                    widget.isEditing.value = false;
                  },
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: widget.isEditing,
              builder: (context, value, child) =>
                  value ? child! : const SizedBox.shrink(),
              child: Align(
                alignment: Alignment.topRight,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: textEditingController,
                  builder: (context, value, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        onPressed: value.text.isEmpty
                            ? null
                            : () {
                                widget.isEditing.value = false;
                                context.read<CommentBloc>().add(CommentSent(
                                      content: value.text,
                                      replyTo: comment,
                                      postId: widget.postId,
                                    ));
                              },
                        child: const Text('comment.list.send').tr(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
