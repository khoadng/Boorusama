// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({
    super.key,
    this.errorMessage,
    this.child,
  });

  final Widget? child;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 50),
        Lottie.asset(
          'assets/animations/server-error.json',
          width: MediaQuery.of(context).size.width,
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
      ],
    );
  }
}
