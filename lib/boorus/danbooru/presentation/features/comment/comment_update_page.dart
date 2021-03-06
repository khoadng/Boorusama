// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/generated/i18n.dart';
import 'widgets/editor_spacer.dart';

class CommentUpdatePage extends HookWidget {
  const CommentUpdatePage({
    Key key,
    @required this.postId,
    @required this.commentId,
    this.initialContent,
  }) : super(key: key);

  final int commentId;
  final String initialContent;
  final int postId;

  void _handleSave(BuildContext context, String content) {
    FocusScope.of(context).unfocus();
    context.read(commentProvider).updateComment(commentId, content);
  }

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
                        IconButton(
                            onPressed: () {
                              _handleSave(context, textEditingController.text);
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.save)),
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
}
