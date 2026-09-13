// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../settings/data.dart';
import '../../../../settings/widgets.dart';

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
    return SettingAnchor(
      id: SettingsIndex.profileSearch.hideDeleted.id,
      child: KurumiSwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SettingsIndex.profileSearch.hideDeleted.title(context)),
        value: value ?? false,
        onChanged: onChanged,
        subtitle: subtitle,
      ),
    );
  }
}
