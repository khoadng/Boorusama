// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final textEditingController = useTextEditingController(text: initialContent ?? "");

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
                        IconButton(
                            onPressed: () {
                              _handleSend(context, textEditingController.text);
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.send)),
                      ],
                    ),
                  ),
                  EditorSpacer(),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(hintText: 'commentCreate.hint'.tr()),
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
    context.read(commentProvider).postComment(postId, content);
  }
}
