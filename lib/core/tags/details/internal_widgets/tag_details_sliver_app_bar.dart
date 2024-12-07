// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';

class TagDetailsSlilverAppBar extends ConsumerWidget {
  const TagDetailsSlilverAppBar({
    super.key,
    required this.tagName,
  });

  final String tagName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      backgroundColor: context.colorScheme.surface,
      actions: [
        IconButton(
          splashRadius: 20,
          onPressed: () {
            goToBulkDownloadPage(
              context,
              [tagName],
              ref: ref,
            );
          },
          icon: const Icon(Symbols.download),
        ),
      ],
    );
  }
}
