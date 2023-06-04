// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/tags/tags.dart';
import 'package:boorusama/boorus/core/ui/search/common/option_tags_arena.dart';

class MetatagsSection extends StatefulWidget {
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
  State<MetatagsSection> createState() => _MetatagsSectionState();
}

class _MetatagsSectionState extends State<MetatagsSection> {
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
      ...widget.userMetatags().map((tag) => RawChip(
            label: Text(tag),
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
          )),
      if (editMode)
        IconButton(
          iconSize: 28,
          splashRadius: 20,
          onPressed: () => goToMetatagsPage(
            context,
            metatags: metatags,
            onSelected: (tag) => setState(() {
              Navigator.of(context).pop();
              widget.onUserMetatagAdded(tag);
            }),
          ),
          icon: const Icon(Icons.add),
        ),
    ];
  }
}
