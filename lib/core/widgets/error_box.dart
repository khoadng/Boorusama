// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({
    super.key,
    this.errorMessage,
    this.child,
    this.onRetry,
  });

  final Widget? child;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 50),
        Lottie.asset(
          'assets/animations/server-error.json',
          width: MediaQuery.sizeOf(context).width,
          height: 400,
          fit: BoxFit.contain,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            errorMessage ?? 'generic.errors.unknown',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ).tr(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
