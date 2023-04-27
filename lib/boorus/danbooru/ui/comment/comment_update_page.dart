// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'widgets/editor_spacer.dart';

class CommentUpdatePage extends StatefulWidget {
  const CommentUpdatePage({
    super.key,
    required this.postId,
    required this.commentId,
    this.initialContent,
  });

  final int commentId;
  final String? initialContent;
  final int postId;

  @override
  State<CommentUpdatePage> createState() => _CommentUpdatePageState();
}

class _CommentUpdatePageState extends State<CommentUpdatePage> {
  late final textEditingController =
      TextEditingController(text: widget.initialContent);

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                        const Expanded(
                          child: Center(),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _handleSave(textEditingController.text);
                          },
                          icon: const Icon(Icons.save),
                        ),
                      ],
                    ),
                  ),
                  const EditorSpacer(),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'comment.create.hint'.tr(),
                      ),
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

  void _handleSave(String content) {
    FocusScope.of(context).unfocus();
    context.read<CommentBloc>().add(CommentUpdated(
          commentId: widget.commentId,
          postId: widget.postId,
          content: content,
        ));
  }
}
