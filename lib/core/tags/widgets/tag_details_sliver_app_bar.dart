// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/foundation/theme.dart';

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
      backgroundColor: context.theme.scaffoldBackgroundColor,
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
