// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class CreateBooruImageDetailsResolutionOptionTile<T> extends StatelessWidget {
  const CreateBooruImageDetailsResolutionOptionTile({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
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
      title: const Text("Details page's image resolution"),
      subtitle: const Text(
        'Higher resolution will take longer to load.',
      ),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: item,
        onChanged: (value) => onChanged(value),
        items: items
            .append('Auto')
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.sentenceCase),
                ))
            .toList(),
      ),
    );
  }
}

class CreateBooruGeneralPostDetailsResolutionOptionTile
    extends StatelessWidget {
  const CreateBooruGeneralPostDetailsResolutionOptionTile({
    super.key,
    required this.value,
    required this.onChanged,
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
