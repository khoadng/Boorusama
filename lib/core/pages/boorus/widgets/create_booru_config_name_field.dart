// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/login_field.dart';

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
    return LoginField(
      controller: controller,
      validator: (p0) => null,
      labelText: 'booru.config_name_label'.tr(),
      onChanged: widget.onChanged,
      hintText: 'A label to identify this profile',
    );
  }
}
