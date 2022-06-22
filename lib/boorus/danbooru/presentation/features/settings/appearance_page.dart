// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({
    Key? key,
    required this.settings,
  }) : super(key: key);

  final Settings settings;

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.appSettings.appearance._string'.tr()),
      ),
      body: SingleChildScrollView(
        child: Column(),
      ),
    );
  }
}
