// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:

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
    return KurumiSwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.t.booru.hide_deleted_label),
      value: value ?? false,
      onChanged: onChanged,
      subtitle: subtitle,
    );
  }
}
