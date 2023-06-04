// Flutter imports:
import 'package:flutter/material.dart';

class ContextMenu<T> extends StatefulWidget {
  const ContextMenu({
    required this.items,
    required this.onSelected,
    required this.child,
    super.key,
  });

  final List<PopupMenuEntry<T>> items;
  final void Function(T value) onSelected;
  final Widget child;

  @override
  State<ContextMenu<T>> createState() => ContextMenuState<T>();
}

class ContextMenuState<T> extends State<ContextMenu<T>> {
  Offset? _tapDownPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _tapDownPosition = details.globalPosition,
      onLongPress: () async {
        final overlay = Overlay.of(context).context.findRenderObject();
        if (overlay == null) return;
        if (_tapDownPosition == null) return;

        final value = await showMenu(
          context: context,
          items: widget.items,
          position: RelativeRect.fromLTRB(
            _tapDownPosition!.dx,
            _tapDownPosition!.dy,
            overlay.semanticBounds.width - _tapDownPosition!.dx,
            overlay.semanticBounds.height - _tapDownPosition!.dy,
          ),
        );
        if (value != null) {
          widget.onSelected(value);
        }
      },
      child: widget.child,
    );
  }
}
