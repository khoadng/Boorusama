// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';

class AppearancePage extends StatefulWidget {
  AppearancePage({
    Key? key,
    required this.settings,
  }) : super(key: key);

  final Settings settings;

  @override
  _AppearancePageState createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.appSettings.appearance._string'.tr()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Text('settings.appSettings.appearance.theme._string'.tr()),
            // RadioListTile<ThemeMode>(
            //   title: Text('settings.appSettings.appearance.theme.dark'.tr()),
            //   value: ThemeMode.dark,
            //   groupValue: widget.settings.themeMode,
            //   onChanged: (value) => setTheme(value, context),
            // ),
            // RadioListTile<ThemeMode>(
            //   title: Text('settings.appSettings.appearance.theme.light'.tr()),
            //   value: ThemeMode.light,
            //   groupValue: widget.settings.themeMode,
            //   onChanged: (value) => setTheme(value, context),
            // ),
          ],
        ),
      ),
    );
  }
}
