// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/pages/search/common/option_tags_arena.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'favorite_tags/add_tag_button.dart';

class MetatagsSection extends ConsumerStatefulWidget {
  const MetatagsSection({
    super.key,
    required this.onOptionTap,
    required this.metatags,
    required this.userMetatags,
    this.onHelpRequest,
    required this.onUserMetatagDeleted,
    required this.onUserMetatagAdded,
  });

  final ValueChanged<String>? onOptionTap;
  final List<Metatag> metatags;
  final List<String> Function() userMetatags;
  final void Function()? onHelpRequest;
  final Future<void> Function(String tag) onUserMetatagDeleted;
  final Future<void> Function(Metatag tag) onUserMetatagAdded;

  @override
  ConsumerState<MetatagsSection> createState() => _MetatagsSectionState();
}

class _MetatagsSectionState extends ConsumerState<MetatagsSection> {
  @override
  Widget build(BuildContext context) {
    return OptionTagsArena(
      title: 'Metatags',
      titleTrailing: (editMode) => widget.onHelpRequest != null
          ? IconButton(
              onPressed: widget.onHelpRequest,
              icon: const FaIcon(
                FontAwesomeIcons.circleQuestion,
                size: 18,
              ),
            )
          : const SizedBox.shrink(),
      childrenBuilder: (editMode) =>
          _buildMetatags(context, editMode, widget.metatags),
    );
  }

  List<Widget> _buildMetatags(
    BuildContext context,
    bool editMode,
    List<Metatag> metatags,
  ) {
    return [
      ...widget.userMetatags().map((tag) {
        final colors = context.generateChipColors(
          context.colorScheme.primary,
          ref.watch(settingsProvider),
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
          onDeleted: editMode
              ? () async {
                  await widget.onUserMetatagDeleted.call(tag);
                  setState(() => {});
                }
              : null,
        );
      }),
      if (editMode)
        AddTagButton(
          onPressed: () => goToMetatagsPage(
            context,
            metatags: metatags,
            onSelected: (tag) {
              widget.onUserMetatagAdded(tag);
            },
          ),
        ),
    ];
  }
}
