// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';

class CreateBooruHideDeletedSwitch extends StatelessWidget {
  const CreateBooruHideDeletedSwitch({
    super.key,
    required this.onChanged,
    this.value,
    this.subtitle,
  });

  final void Function(bool value) onChanged;
  final Widget? subtitle;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    print('CreateBooruHideDeletedSwitch');

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('booru.hide_deleted_label').tr(),
      value: value ?? false,
      onChanged: onChanged,
      subtitle: subtitle,
    );
  }
}
