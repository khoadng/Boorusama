// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

class CreateBooruSubmitButton extends StatelessWidget {
  const CreateBooruSubmitButton({
    required this.onSubmit,
    super.key,
    this.backgroundColor,
    this.child,
    this.fill = false,
  });

  final bool fill;
  final void Function()? onSubmit;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (fill) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
        ),
        onPressed: onSubmit,
        child: child ?? const Text('booru.config_booru_confirm').tr(),
      );
    }

    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
      onPressed: onSubmit,
      child: child ?? const Text('Save'),
    );
  }
}
