// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';

class CreateBooruSubmitButton extends StatelessWidget {
  const CreateBooruSubmitButton({
    super.key,
    required this.onSubmit,
  });

  final void Function()? onSubmit;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onSubmit,
      child: const Text('booru.config_booru_confirm').tr(),
    );
  }
}
