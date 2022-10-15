import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NoDataBox extends StatelessWidget {
  const NoDataBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: Center(
        child: Text(
          'generic.errors.no_data',
          style: Theme.of(context).textTheme.titleLarge,
        ).tr(),
      ),
    );
  }
}
