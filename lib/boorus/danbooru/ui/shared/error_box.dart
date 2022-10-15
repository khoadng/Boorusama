// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: Center(
        child: Text(
          'generic.errors.unknown',
          style: Theme.of(context).textTheme.titleLarge,
        ).tr(),
      ),
    );
  }
}
