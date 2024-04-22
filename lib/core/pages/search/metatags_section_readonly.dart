// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/pages/search/common/option_tags_arena.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class MetatagsSectionReadonly extends ConsumerStatefulWidget {
  const MetatagsSectionReadonly({
    super.key,
    required this.onOptionTap,
    required this.metatags,
  });

  final ValueChanged<String>? onOptionTap;
  final List<Metatag> metatags;

  @override
  ConsumerState<MetatagsSectionReadonly> createState() =>
      _MetatagsSectionState();
}

class _MetatagsSectionState extends ConsumerState<MetatagsSectionReadonly> {
  @override
  Widget build(BuildContext context) {
    return OptionTagsArena(
      title: 'Options',
      childrenBuilder: (_) => _buildMetatags(context, widget.metatags),
      editable: false,
    );
  }

  List<Widget> _buildMetatags(
    BuildContext context,
    List<Metatag> metatags,
  ) {
    return [
      ...widget.metatags.map((tag) {
        final colors = context.generateChipColors(
          context.colorScheme.primary,
          ref.watch(settingsProvider),
        );
        return RawChip(
          visualDensity: VisualDensity.compact,
          label:
              Text(tag.name, style: TextStyle(color: colors?.foregroundColor)),
          backgroundColor: colors?.backgroundColor,
          side: colors != null ? BorderSide(color: colors.borderColor) : null,
          onPressed: () => widget.onOptionTap?.call(tag.name),
          deleteIcon: Icon(
            Symbols.close,
            size: 18,
            color: colors?.foregroundColor,
          ),
        );
      }),
    ];
  }
}
