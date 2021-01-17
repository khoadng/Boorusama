import 'package:boorusama/application/comment/comment_state_notifier.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/all.dart';

import 'comment_page.dart';
import 'widgets/editor_spacer.dart';

class CommentUpdatePage extends HookWidget {
  const CommentUpdatePage({
    Key key,
    @required this.postId,
    @required this.commentId,
    this.initialContent,
  }) : super(key: key);

  final int postId;
  final int commentId;
  final String initialContent;

  @override
  Widget build(BuildContext context) {
    final textEditingController =
        useTextEditingController(text: initialContent ?? "");

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          margin: const EdgeInsets.all(4),
          child: Material(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                        Expanded(
                          child: Center(),
                        ),
                        ProviderListener<CommentState>(
                          provider: commentStateNotifierProvider.state,
                          onChange: (context, state) =>
                              _handleCommentStateChanged(state, context),
                          child: IconButton(
                              onPressed: () => _handleSave(
                                  context, textEditingController.text),
                              icon: Icon(Icons.save)),
                        ),
                      ],
                    ),
                  ),
                  EditorSpacer(),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                          hintText: I18n.of(context).commentCreateHint),
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCommentStateChanged(CommentState state, BuildContext context) {
    state.maybeWhen(
      updatedSuccess: () {
        context.read(commentStateNotifierProvider).getComments(postId);

        Navigator.of(context).pop();
      },
      loading: () => Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(I18n.of(context).commentCreateLoading))),
      error: () => Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(I18n.of(context).commentCreateError))),
      orElse: () {},
    );
  }

  void _handleSave(BuildContext context, String content) {
    FocusScope.of(context).unfocus();
    context
        .read(commentStateNotifierProvider)
        .updateComment(commentId, postId, content);
  }
}
