// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:lottie/lottie.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Lottie.asset(
                'assets/animations/server-error.json',
                fit: BoxFit.scaleDown,
              ),
            ),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
