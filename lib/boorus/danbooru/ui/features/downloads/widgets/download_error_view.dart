// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

class DownloadErrorView extends StatelessWidget {
  const DownloadErrorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text('general.errors.unknown').tr(),
    );
  }
}
