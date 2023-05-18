// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/core/router.dart';

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
