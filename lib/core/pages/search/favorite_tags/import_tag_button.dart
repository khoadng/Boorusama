// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class ImportTagButton extends ConsumerWidget {
  const ImportTagButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      style: FilledButton.styleFrom(shape: const StadiumBorder()),
      onPressed: () => goToFavoriteTagImportPage(
        context,
        ref,
      ),
      child: const Text('favorite_tags.import').tr(),
    );
  }
}
