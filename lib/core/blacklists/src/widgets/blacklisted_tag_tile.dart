// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../widgets/widgets.dart';

class BlacklistedTagTile extends StatelessWidget {
  const BlacklistedTagTile({
    required this.tag,
    required this.onEditTap,
    required this.onRemoveTag,
    super.key,
  });

  final String tag;
  final VoidCallback onEditTap;
  final void Function(String tag) onRemoveTag;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tag),
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 'remove':
              onRemoveTag.call(tag);
            case 'edit':
              onEditTap.call();
          }
        },
        itemBuilder: {
          'remove': Text(context.t.blacklisted_tags.remove),
          'edit': Text(context.t.blacklisted_tags.edit),
        },
      ),
    );
  }
}
