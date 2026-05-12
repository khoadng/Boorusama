// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../widgets/widgets.dart';

class CommentEditorPage extends StatefulWidget {
  const CommentEditorPage({
    required this.onSubmit,
    super.key,
    this.initialContent,
    this.submitIcon = Symbols.save,
  });

  final String? initialContent;
  final IconData submitIcon;
  final void Function(String content) onSubmit;

  @override
  State<CommentEditorPage> createState() => _CommentEditorPageState();
}

class _CommentEditorPageState extends State<CommentEditorPage> {
  late final textEditingController = TextEditingController(
    text: widget.initialContent,
  );
  var _popping = false;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _popping,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _popping) return;
        _closeWithDraft();
      },
      child: Scaffold(
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
                            onPressed: _closeWithDraft,
                            icon: const Icon(Symbols.close),
                          ),
                          const Expanded(
                            child: Center(),
                          ),
                          IconButton(
                            onPressed: _submit,
                            icon: Icon(widget.submitIcon),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: BooruTextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: '${context.t.comment.create.hint}...',
                          filled: false,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
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
      ),
    );
  }

  void _closeWithDraft() {
    _pop(textEditingController.text);
  }

  void _submit() {
    final content = textEditingController.text;
    _pop('');
    widget.onSubmit(content);
  }

  void _pop(String result) {
    if (_popping) return;

    setState(() => _popping = true);
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    });
  }
}
