// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

class NoDataBox extends StatelessWidget {
  const NoDataBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 50),
        Lottie.asset(
          'assets/animations/search-file.json',
          width: MediaQuery.of(context).size.width,
          height: 300,
          fit: BoxFit.contain,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const Text(
            'generic.errors.no_data',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ).tr(),
        ),
      ],
    );
  }
}
