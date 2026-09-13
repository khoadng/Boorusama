// Package imports:
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../posts/post/types.dart';
import '../../../settings/data.dart';
import '../../../settings/widgets.dart';

class CreateBooruGeneralPostDetailsResolutionOptionTile
    extends StatelessWidget {
  const CreateBooruGeneralPostDetailsResolutionOptionTile({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String? value;
  final void Function(String? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return CreateBooruImageDetailsResolutionOptionTile(
      value: value,
      items: GeneralPostQualityType.values.map((e) => e.stringify()).toList(),
      onChanged: (value) => onChanged(value),
    );
  }
}

class CreateBooruImageDetailsResolutionOptionTile<T> extends StatelessWidget {
  const CreateBooruImageDetailsResolutionOptionTile({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final List<String> items;
  final String? value;
  final void Function(String? value) onChanged;

  @override
  Widget build(BuildContext context) {
    // set to Auto when value is null or empty
    final item = (value?.isNotEmpty ?? false) ? value : 'Auto';

    return SettingAnchor(
      id: SettingsIndex.viewer.imageQuality.id,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        title: Text(
          SettingsIndex.viewer.imageQuality.title(context),
        ),
        subtitle: Text(
          context.t.settings.image_grid.image_quality.high_quality_notice,
        ),
        trailing: KurumiOptionDropDownButton(
          alignment: AlignmentDirectional.centerStart,
          value: item,
          onChanged: (value) => onChanged(value),
          items: items
              .append('Auto')
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: e == 'Auto'
                      ? Text(context.t.settings.image_grid.image_quality.auto)
                      : Text(e.sentenceCase),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
