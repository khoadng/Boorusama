// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

class CreateBooruHideDeletedSwitch extends StatelessWidget {
  const CreateBooruHideDeletedSwitch({
    required this.onChanged,
    super.key,
    this.value,
    this.subtitle,
  });

  final void Function(bool value) onChanged;
  final Widget? subtitle;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('booru.hide_deleted_label').tr(),
      value: value ?? false,
      onChanged: onChanged,
      subtitle: subtitle,
    );
  }
}
