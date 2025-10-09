// Flutter imports:
import 'package:flutter/widgets.dart';

enum EditorTool {
  interact,
  draw,
  move;

  bool get isEditable => this == EditorTool.draw || this == EditorTool.move;
  bool get isInteractive => this == EditorTool.interact;

  String getLabel(BuildContext context) => switch (this) {
    EditorTool.interact => 'Interact',
    EditorTool.draw => 'Add',
    EditorTool.move => 'Move/Edit',
  };
}
