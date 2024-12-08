// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/platform.dart';

class OptionTagsArenaController extends ChangeNotifier {
  final ValueNotifier<bool> editMode = ValueNotifier(false);

  void toggleEditMode() {
    editMode.value = !editMode.value;
    notifyListeners();
  }
}

class OptionTagsArena extends StatefulWidget {
  const OptionTagsArena({
    super.key,
    required this.title,
    this.titleTrailing,
    required this.children,
    this.editable = true,
    this.controller,
  });

  final String title;
  final Widget? titleTrailing;
  final List<Widget> children;
  final bool editable;
  final OptionTagsArenaController? controller;

  @override
  State<OptionTagsArena> createState() => _OptionTagsArenaState();
}

class _OptionTagsArenaState extends State<OptionTagsArena> {
  late final controller = widget.controller ?? OptionTagsArenaController();

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Wrap(
          spacing: 4,
          runSpacing: isDesktopPlatform() ? 4 : 0,
          children: widget.children,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.title.toUpperCase(),
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.editable)
              ValueListenableBuilder(
                valueListenable: controller.editMode,
                builder: (context, editMode, child) {
                  return FilledButton(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(32, 32),
                      shape: const CircleBorder(),
                      backgroundColor: editMode
                          ? context.colorScheme.primary
                          : context.colorScheme.surfaceContainerHighest,
                    ),
                    onPressed: () => controller.toggleEditMode(),
                    child: Icon(
                      editMode ? Symbols.check : Symbols.edit,
                      size: 16,
                      color: editMode
                          ? context.colorScheme.onPrimary
                          : context.colorScheme.onSurfaceVariant,
                      fill: 1,
                    ),
                  );
                },
              ),
          ],
        ),
        widget.titleTrailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
