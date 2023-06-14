// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/editor_spacer.dart';

class CommentUpdatePage extends ConsumerStatefulWidget {
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
  ConsumerState<CommentUpdatePage> createState() => _CommentUpdatePageState();
}

class _CommentUpdatePageState extends ConsumerState<CommentUpdatePage> {
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
                          onPressed: () => context.navigator.pop(),
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                        const Expanded(
                          child: Center(),
                        ),
                        IconButton(
                          onPressed: () {
                            context.navigator.pop();
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
    context.focusScope.unfocus();
    ref.read(danbooruCommentsProvider.notifier).update(
          postId: widget.postId,
          commentId: widget.commentId,
          content: content,
        );
  }
}
