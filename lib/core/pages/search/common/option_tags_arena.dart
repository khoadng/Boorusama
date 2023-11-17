// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

class OptionTagsArena extends StatefulWidget {
  const OptionTagsArena({
    super.key,
    required this.title,
    this.titleTrailing,
    required this.childrenBuilder,
    this.editable = true,
  });

  final String title;
  final Widget Function(bool editMode)? titleTrailing;
  final List<Widget> Function(bool editMode) childrenBuilder;
  final bool editable;

  @override
  State<OptionTagsArena> createState() => _OptionTagsArenaState();
}

class _OptionTagsArenaState extends State<OptionTagsArena> {
  bool editMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: _buildHeader(),
        ),
        Wrap(
          spacing: 4,
          children: widget.childrenBuilder(editMode),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                widget.title.toUpperCase(),
                style: context.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.editable)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: const CircleBorder(),
                    backgroundColor: editMode
                        ? context.colorScheme.primary
                        : context.theme.cardColor,
                  ),
                  onPressed: () => setState(() => editMode = !editMode),
                  child: Icon(
                    editMode ? Icons.check : Icons.edit,
                    size: 16,
                    color: context.colorScheme.onBackground,
                  ),
                ),
            ],
          ),
          widget.titleTrailing?.call(editMode) ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
