// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateBooruTitleHeader extends StatelessWidget {
  const CreateBooruTitleHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      child: Text(
        'booru.add_booru_source_title',
        style: context.textTheme.headlineSmall!
            .copyWith(fontWeight: FontWeight.w900),
      ).tr(),
    );
  }
}
