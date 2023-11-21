// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/comments/editor_spacer.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';

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
    final config = ref.watchConfig;

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
                    children: [
                      IconButton(
                        onPressed: () => context.navigator.pop(),
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                      const Expanded(child: Center()),
                      IconButton(
                        onPressed: () {
                          context.navigator.pop();
                          _handleSend(textEditingController.text, config);
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
                    decoration: InputDecoration(
                      hintText: 'comment.create.hint'.tr(),
                      filled: false,
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(),
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

  void _handleSend(String content, BooruConfig config) {
    context.focusScope.unfocus();
    ref.read(danbooruCommentsProvider(config).notifier).send(
          postId: widget.postId,
          content: content,
        );
  }
}
