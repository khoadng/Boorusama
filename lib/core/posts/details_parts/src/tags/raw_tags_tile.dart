// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/display/media_query_utils.dart';
import '../../../../configs/config/types.dart';
import '../../../../tags/show/routes.dart';
import '../../../../widgets/booru_popup_menu_button.dart';
import '../../../post/types.dart';
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

class RawTagsTileTitle<T extends Post> extends ConsumerWidget {
  const RawTagsTileTitle({
    required this.count,
    required this.post,
    required this.auth,
    this.menuItems,
    super.key,
  });

  final BooruConfigAuth auth;
  final int? count;
  final T post;
  final List<BooruPopupMenuItem>? menuItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Text(context.t.tags.counter(n: count ?? 0)),
        BooruPopupMenuButton(
          iconColor: Theme.of(context).colorScheme.onSurface,
          items: [
            BooruPopupMenuItem(
              title: Text(context.t.generic.action.select),
              onTap: () {
                goToShowTaglistPage(
                  ref,
                  post,
                  initiallyMultiSelectEnabled: true,
                  auth: auth,
                );
              },
            ),
            ...?menuItems,
          ],
        ),
      ],
    );
  }
}
