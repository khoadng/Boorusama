// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/display/media_query_utils.dart';
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
