import 'package:boorusama/application/comment/comment_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/all.dart';

import 'widgets/editor_spacer.dart';

class CommentCreatePage extends HookWidget {
  const CommentCreatePage({
    Key key,
    @required this.postId,
    this.initialContent,
  }) : super(key: key);

  final int postId;
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
                        Expanded(child: Center()),
                        ProviderListener(
                          provider: commentStateNotifierProvider.state,
                          onChange: (context, state) =>
                              _handleCommentStateChanged(state, context),
                          child: IconButton(
                              onPressed: () => _handleSend(
                                  context, textEditingController.text),
                              icon: Icon(Icons.send)),
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
                      decoration:
                          InputDecoration.collapsed(hintText: 'Comment'),
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

  void _handleSend(BuildContext context, String content) {
    FocusScope.of(context).unfocus();
    context.read(commentStateNotifierProvider).addComment(postId, content);
  }

  void _handleCommentStateChanged(state, BuildContext context) {
    state.maybeWhen(
      addedSuccess: () {
        context.read(commentStateNotifierProvider).getComments(postId);
        Navigator.of(context).pop();
      },
      loading: () => Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Please wait..."))),
      error: () =>
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Error"))),
      orElse: () {},
    );
  }
}
