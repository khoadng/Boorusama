// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/pages/search/common/option_tags_arena.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class MetatagsSection extends ConsumerStatefulWidget {
  const MetatagsSection({
    super.key,
    required this.onOptionTap,
    required this.metatags,
    required this.userMetatags,
    required this.onHelpRequest,
    required this.onUserMetatagDeleted,
    required this.onUserMetatagAdded,
  });

  final ValueChanged<String>? onOptionTap;
  final List<Metatag> metatags;
  final List<String> Function() userMetatags;
  final void Function() onHelpRequest;
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
      titleTrailing: (editMode) => IconButton(
        onPressed: widget.onHelpRequest,
        icon: const FaIcon(
          FontAwesomeIcons.circleQuestion,
          size: 18,
        ),
      ),
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
        final colors =
            generateChipColors(context.colorScheme.primary, context.themeMode);
        return RawChip(
          visualDensity: VisualDensity.compact,
          label: Text(tag, style: TextStyle(color: colors.foregroundColor)),
          backgroundColor: colors.backgroundColor,
          side: BorderSide(color: colors.borderColor),
          onPressed: editMode ? null : () => widget.onOptionTap?.call(tag),
          deleteIcon: const Icon(
            Icons.close,
            size: 18,
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
        IconButton(
          iconSize: 28,
          splashRadius: 20,
          onPressed: () => goToMetatagsPage(
            context,
            metatags: metatags,
            onSelected: (tag) => setState(() {
              context.navigator.pop();
              widget.onUserMetatagAdded(tag);
            }),
          ),
          icon: const Icon(Icons.add),
        ),
    ];
  }
}
