// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:lottie/lottie.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({
    super.key,
    this.errorMessage,
    this.child,
    this.onRetry,
    this.altAction,
  });

  final Widget? child;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? altAction;

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
            errorMessage ?? context.t.generic.errors.unknown,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ?altAction,
              if (onRetry case final onRetry?)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  width: constraints.maxWidth <= 450
                      ? constraints.maxWidth
                      : null,
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ),
                  child: FilledButton(
                    onPressed: onRetry,
                    child: Text(context.t.generic.action.retry),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
