// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../tags/metatag/routes.dart';
import '../../../../tags/metatag/types.dart';
import '../../../../theme/providers.dart';
import 'add_tag_button.dart';
import 'option_tags_arena.dart';

class MetatagsSection extends ConsumerStatefulWidget {
  const MetatagsSection({
    required this.onOptionTap,
    required this.metatags,
    required this.userMetatags,
    required this.onUserMetatagDeleted,
    required this.onUserMetatagAdded,
    super.key,
    this.onHelpRequest,
  });

  final ValueChanged<String>? onOptionTap;
  final List<Metatag> metatags;
  final List<String>? userMetatags;
  final void Function()? onHelpRequest;
  final Future<void> Function(String tag) onUserMetatagDeleted;
  final Future<void> Function(Metatag tag) onUserMetatagAdded;

  @override
  ConsumerState<MetatagsSection> createState() => _MetatagsSectionState();
}

class _MetatagsSectionState extends ConsumerState<MetatagsSection> {
  final controller = OptionTagsArenaController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userMetatags = widget.userMetatags;

    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 10,
      ),
      child: OptionTagsArena(
        controller: controller,
        title: 'Metatags',
        titleTrailing: widget.onHelpRequest != null
            ? IconButton(
                onPressed: widget.onHelpRequest,
                icon: const FaIcon(
                  FontAwesomeIcons.circleQuestion,
                  size: 18,
                ),
              )
            : const SizedBox.shrink(),
        children: [
          if (userMetatags != null)
            ...userMetatags.map(
              (tag) => ValueListenableBuilder(
                valueListenable: controller.editMode,
                builder: (context, editMode, _) => _buildChip(tag, editMode),
              ),
            ),
          ValueListenableBuilder(
            valueListenable: controller.editMode,
            builder: (context, editMode, _) =>
                _buildAddButton(context, widget.metatags),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String tag, bool editMode) {
    final colors = ref
        .watch(booruChipColorsProvider)
        .fromColor(
          Theme.of(context).colorScheme.primary,
        );

    return RawChip(
      visualDensity: VisualDensity.compact,
      label: Text(tag, style: TextStyle(color: colors?.foregroundColor)),
      backgroundColor: colors?.backgroundColor,
      side: colors != null ? BorderSide(color: colors.borderColor) : null,
      onPressed: editMode ? null : () => widget.onOptionTap?.call(tag),
      deleteIcon: Icon(
        Symbols.close,
        size: 18,
        color: colors?.foregroundColor,
      ),
      onDeleted: editMode ? () => widget.onUserMetatagDeleted(tag) : null,
    );
  }

  Widget _buildAddButton(BuildContext context, List<Metatag> metatags) {
    return AddTagButton(
      onPressed: () => goToMetatagsPage(
        context,
        metatags: metatags,
        onSelected: (tag) {
          widget.onUserMetatagAdded(tag);
        },
      ),
    );
  }
}
