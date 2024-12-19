// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickPreviewImageDialog extends StatelessWidget {
  const QuickPreviewImageDialog({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: const Color.fromARGB(189, 0, 0, 0),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
