// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/comments/comments.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/editor_spacer.dart';

class CommentCreatePage extends ConsumerStatefulWidget {
  const CommentCreatePage({
    super.key,
    required this.postId,
    this.initialContent,
  });

  final int postId;
  final String? initialContent;

  @override
  ConsumerState<CommentCreatePage> createState() => _CommentCreatePageState();
}

class _CommentCreatePageState extends ConsumerState<CommentCreatePage> {
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          Navigator.of(context).pop();
                          _handleSend(textEditingController.text);
                        },
                        icon: const Icon(Icons.send),
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
    );
  }

  void _handleSend(String content) {
    FocusScope.of(context).unfocus();
    ref.read(danbooruCommentsProvider.notifier).send(
          postId: widget.postId,
          content: content,
        );
  }
}
