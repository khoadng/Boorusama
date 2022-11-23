// Flutter imports:
import 'package:flutter/material.dart';

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
          runSpacing: -4,
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
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (widget.editable)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: const CircleBorder(),
                    backgroundColor: editMode
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                  ),
                  onPressed: () => setState(() => editMode = !editMode),
                  child: Icon(
                    editMode ? Icons.check : Icons.edit,
                    size: 16,
                    color: Theme.of(context).colorScheme.onBackground,
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
