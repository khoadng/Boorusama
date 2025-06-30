// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../posts/post/post.dart';
import '../../../widgets/widgets.dart';

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
    final item = value?.isNotEmpty == true ? value : 'Auto';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: const Text('settings.image_grid.image_quality.image_quality').tr(),
      subtitle: const Text(
        'Higher quality will take longer to load.',
      ),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: item,
        onChanged: (value) => onChanged(value),
        items: items
            .append('Auto')
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e.sentenceCase),
              ),
            )
            .toList(),
      ),
    );
  }
}
