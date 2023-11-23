// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';

class CreateBooruConfigNameField extends StatefulWidget {
  const CreateBooruConfigNameField({
    super.key,
    required this.onChanged,
    this.text,
  });

  final void Function(String value) onChanged;
  final String? text;

  @override
  State<CreateBooruConfigNameField> createState() =>
      _CreateBooruConfigNameFieldState();
}

class _CreateBooruConfigNameFieldState
    extends State<CreateBooruConfigNameField> {
  late var controller = TextEditingController(text: widget.text);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: BooruTextFormField(
        controller: controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'A label to identify this profile',
          labelText: 'booru.config_name_label'.tr(),
        ),
      ),
    );
  }
}
