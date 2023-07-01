// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';

class CreateBooruHideDeletedSwitch extends StatelessWidget {
  const CreateBooruHideDeletedSwitch({
    super.key,
    required this.onChanged,
    this.value = false,
  });

  final void Function(bool value) onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: const Text('booru.hide_deleted_label').tr(),
      value: false,
      onChanged: onChanged,
    );
  }
}
