// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/display/media_query_utils.dart';
import '../../../../widgets/booru_popup_menu_button.dart';
import '../_internal/details_widget_frame.dart';

class RawTagsTile extends StatelessWidget {
  const RawTagsTile({
    required this.title,
    required this.children,
    super.key,
    this.onExpansionChanged,
    this.initiallyExpanded = false,
    this.trailing,
    this.controlAffinity = ListTileControlAffinity.trailing,
  });

  final Widget title;
  final List<Widget> children;
  final void Function(bool)? onExpansionChanged;
  final bool initiallyExpanded;
  final Widget? trailing;
  final ListTileControlAffinity controlAffinity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DetailsWidgetSeparator(
      child: Theme(
        data: theme.copyWith(
          listTileTheme: theme.listTileTheme.copyWith(
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
          ),
          dividerColor: Colors.transparent,
        ),
        child: RemoveLeftPaddingOnLargeScreen(
          child: DetailsWidgetSeparator(
            child: ExpansionTile(
              initiallyExpanded: initiallyExpanded,
              title: title,
              trailing: trailing,
              controlAffinity: controlAffinity,
              onExpansionChanged: onExpansionChanged,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class RawTagsTileTitle<T> extends StatelessWidget {
  const RawTagsTileTitle({
    required this.count,
    this.itemBuilder,
    this.onSelected,
    super.key,
  });

  final int count;
  final Map<T, Widget>? itemBuilder;
  final void Function(T value)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$count tags'),
        if (itemBuilder?.isNotEmpty ?? false)
          BooruPopupMenuButton(
            iconColor: Theme.of(context).colorScheme.onSurface,
            onSelected: onSelected,
            itemBuilder: itemBuilder ?? <T, Widget>{},
          ),
      ],
    );
  }
}
