// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../widgets/widgets.dart';

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
    return BooruSwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.t.booru.hide_deleted_label),
      value: value ?? false,
      onChanged: onChanged,
      subtitle: subtitle,
    );
  }
}
