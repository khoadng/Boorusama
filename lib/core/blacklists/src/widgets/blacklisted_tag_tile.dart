// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../widgets/widgets.dart';

class BlacklistedTagTile extends StatelessWidget {
  const BlacklistedTagTile({
    super.key,
    required this.tag,
    required this.onEditTap,
    required this.onRemoveTag,
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
              break;
            case 'edit':
              onEditTap.call();
              break;
          }
        },
        itemBuilder: {
          'remove': const Text('blacklisted_tags.remove').tr(),
          'edit': const Text('blacklisted_tags.edit').tr(),
        },
      ),
    );
  }
}
