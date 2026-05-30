// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../themes/theme/types.dart';
import '../../../widgets/widgets.dart';

class CommentComposer extends StatefulWidget {
  const CommentComposer({
    required this.onSubmit,
    super.key,
    this.focusNode,
    this.isEditing,
    this.header,
    this.suffixIcon,
    this.suffixIconBuilder,
    this.onOpenEditor,
  });

  final FocusNode? focusNode;
  final ValueNotifier<bool>? isEditing;
  final Widget? header;
  final Widget? suffixIcon;
  final Widget Function(BuildContext context, TextEditingController controller)?
  suffixIconBuilder;
  final Future<String?> Function(String text)? onOpenEditor;
  final Future<void> Function(String text) onSubmit;

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  late final textEditingController = TextEditingController();
  var sending = false;

  @override
  void initState() {
    super.initState();
    widget.isEditing?.addListener(_onEditing);
  }

  @override
  void dispose() {
    widget.isEditing?.removeListener(_onEditing);
    textEditingController.dispose();
    super.dispose();
  }

  void _onEditing() {
    if (widget.isEditing?.value == false) {
      textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        top: 8,
        left: 12,
        right: 12,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?widget.header,
          BooruTextField(
            focusNode: widget.focusNode,
            controller: textEditingController,
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.hintColor,
              ),
              hintText: context.t.comment.create.hint,
              suffixIcon: _buildSuffixIcon(context),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
          ValueListenableBuilder(
            valueListenable: textEditingController,
            builder: (context, value, child) {
              final showButton = widget.isEditing?.value ?? true;

              if (!showButton) return const SizedBox.shrink();

              return Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                    onPressed: sending || value.text.trim().isEmpty
                        ? null
                        : () async {
                            setState(() => sending = true);
                            try {
                              await widget.onSubmit(value.text.trim());
                              textEditingController.clear();
                              if (widget.isEditing != null) {
                                widget.isEditing!.value = false;
                              }
                            } finally {
                              if (mounted) {
                                setState(() => sending = false);
                              }
                            }
                          },
                    child: sending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(context.t.comment.list.send),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.suffixIconBuilder case final builder?) {
      return builder(context, textEditingController);
    }

    if (widget.suffixIcon case final suffixIcon?) {
      return suffixIcon;
    }

    if (widget.onOpenEditor case final onOpenEditor?) {
      return IconButton(
        icon: const Icon(Symbols.fullscreen),
        onPressed: () async {
          final result = await onOpenEditor(textEditingController.text);
          if (!mounted || result == null) return;

          textEditingController.text = result;
          textEditingController.selection = TextSelection.collapsed(
            offset: result.length,
          );
        },
      );
    }

    return null;
  }
}
