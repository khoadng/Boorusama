// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';

class ImportTagButton extends StatelessWidget {
  const ImportTagButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(shape: const StadiumBorder()),
      onPressed: () => goToFavoriteTagImportPage(context),
      child: const Text('favorite_tags.import').tr(),
    );
  }
}
