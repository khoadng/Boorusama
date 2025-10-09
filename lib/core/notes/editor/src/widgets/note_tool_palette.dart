// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/editor_keys.dart';
import '../controllers/note_editor_controller.dart';
import '../types/editor_tool.dart';

class NoteToolPalette extends StatelessWidget {
  const NoteToolPalette({
    super.key,
    required this.controller,
  });

  final NoteEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NoteToolButton(
            key: kViewToolButtonKey,
            icon: const Icon(Icons.pan_tool),
            tool: EditorTool.interact,
            controller: controller,
          ),
          _NoteToolButton(
            key: kDrawToolButtonKey,
            icon: const Icon(Icons.edit),
            tool: EditorTool.draw,
            controller: controller,
          ),
          _NoteToolButton(
            key: kMoveToolButtonKey,
            icon: const Icon(Icons.open_with),
            tool: EditorTool.move,
            controller: controller,
          ),
          if (controller.selectedRectIndex != null)
            IconButton(
              key: kDeleteButtonKey,
              icon: const Icon(Icons.delete),
              onPressed: controller.deleteSelectedRect,
              color: Colors.red,
              tooltip: 'Delete',
            ),
        ],
      ),
    );
  }
}

class _NoteToolButton extends StatelessWidget {
  const _NoteToolButton({
    super.key,
    required this.icon,
    required this.tool,
    required this.controller,
  });

  final Widget icon;
  final EditorTool tool;
  final NoteEditorController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: controller.currentTool,
      builder: (context, currentTool, child) {
        final isSelected = currentTool == tool;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: icon,
              onPressed: () => controller.setTool(tool),
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
              style: IconButton.styleFrom(
                backgroundColor: isSelected
                    ? colorScheme.primaryContainer
                    : null,
              ),
            ),
            Text(
              tool.getLabel(context),
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
          ],
        );
      },
    );
  }
}
