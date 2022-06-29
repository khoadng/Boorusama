// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'widgets/editor_spacer.dart';

class CommentCreatePage extends StatefulWidget {
  const CommentCreatePage({
    Key? key,
    required this.postId,
    this.initialContent,
  }) : super(key: key);

  final int postId;
  final String? initialContent;

  @override
  State<CommentCreatePage> createState() => _CommentCreatePageState();
}

class _CommentCreatePageState extends State<CommentCreatePage> {
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
                        const Expanded(child: Center()),
                        IconButton(
                            onPressed: () {
                              _handleSend(context, textEditingController.text);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.send)),
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
                          hintText: 'commentCreate.hint'.tr()),
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
    context
        .read<CommentBloc>()
        .add(CommentSent(content: content, postId: widget.postId));
  }
}
