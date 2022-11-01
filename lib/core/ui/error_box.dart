// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({
    super.key,
    this.child,
  });

  factory ErrorBox.retryable({
    required void Function() onRetry,
  }) =>
      ErrorBox(
        child: ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      );

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'generic.errors.unknown',
            style: Theme.of(context).textTheme.titleLarge,
          ).tr(),
          const SizedBox(height: 5),
          child ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
