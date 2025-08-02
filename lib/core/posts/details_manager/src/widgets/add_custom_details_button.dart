// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../theme/app_theme.dart';
import '../../../../widgets/dotted_border.dart';
import '../routes/route_utils.dart';

class AddCustomDetailsButton extends ConsumerWidget {
  const AddCustomDetailsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: DottedBorderButton(
        borderColor: Theme.of(context).colorScheme.hintColor,
        onTap: () {
          goToDetailsLayoutManagerForFullWidgets(ref);
        },
        title: context.t.settings.appearance.customize,
      ),
    );
  }
}
