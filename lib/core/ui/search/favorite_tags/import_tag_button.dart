// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class ImportTagButton extends StatelessWidget {
  const ImportTagButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
      onPressed: () => goToFavoriteTagImportPage(
        context,
      ),
      child: const Text('favorite_tags.import').tr(),
    );
  }
}
