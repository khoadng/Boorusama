// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/option_dropdown_button.dart';

class CreateBooruRatingOptionsTile extends StatelessWidget {
  const CreateBooruRatingOptionsTile({
    super.key,
    required this.onChanged,
    this.value,
  });

  final void Function(BooruConfigRatingFilter? value) onChanged;
  final BooruConfigRatingFilter? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: const Text('booru.content_filtering_label').tr(),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: value ?? BooruConfigRatingFilter.none,
        onChanged: onChanged,
        items: BooruConfigRatingFilter.values
            .map((value) => DropdownMenuItem<BooruConfigRatingFilter>(
                  value: value,
                  child: Text(value.getFilterRatingTerm()),
                ))
            .toList(),
      ),
    );
  }
}
