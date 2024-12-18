// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../comment/providers.dart';
import '../widgets/editor_spacer.dart';

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
    final config = ref.watchConfigAuth;

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
                        const Expanded(
                          child: Center(),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _handleSave(textEditingController.text, config);
                          },
                          icon: const Icon(Symbols.save),
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
      ),
    );
  }

  void _handleSave(String content, BooruConfigAuth config) {
    FocusScope.of(context).unfocus();
    ref.read(danbooruCommentsProvider(config).notifier).update(
          postId: widget.postId,
          commentId: widget.commentId,
          content: content,
        );
  }
}
