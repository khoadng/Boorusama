// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';

class CreateBooruSubmitButton extends StatelessWidget {
  const CreateBooruSubmitButton({
    super.key,
    required this.onSubmit,
    this.backgroundColor,
    this.child,
  });

  final void Function()? onSubmit;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
      onPressed: onSubmit,
      child: child ?? const Text('booru.config_booru_confirm').tr(),
    );
  }
}
