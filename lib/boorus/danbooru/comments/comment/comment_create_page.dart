// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'comments_notifier.dart';
import 'internal_widgets/editor_spacer.dart';

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
    final config = ref.watchConfigAuth;

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
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Symbols.close,
                        ),
                      ),
                      const Expanded(child: Center()),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _handleSend(textEditingController.text, config);
                        },
                        icon: const Icon(Symbols.send),
                      ),
                    ],
                  ),
                ),
                const EditorSpacer(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: BooruTextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      filled: false,
                      focusedBorder: InputBorder.none,
                      hintText: '${'comment.create.hint'.tr()}...',
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

  void _handleSend(String content, BooruConfigAuth config) {
    FocusScope.of(context).unfocus();
    ref.read(danbooruCommentsProvider(config).notifier).send(
          postId: widget.postId,
          content: content,
        );
  }
}
