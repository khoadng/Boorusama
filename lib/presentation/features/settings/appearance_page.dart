import 'package:boorusama/application/themes/theme_state_notifier.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

class AppearancePage extends StatefulWidget {
  AppearancePage({Key key, @required this.settings}) : super(key: key);

  final Setting settings;

  @override
  _AppearancePageState createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).settingsAppSettingsAppearance_string),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(I18n.of(context).settingsAppSettingsAppearanceTheme_string),
            RadioListTile<ThemeMode>(
              title:
                  Text(I18n.of(context).settingsAppSettingsAppearanceThemeDark),
              value: ThemeMode.dark,
              groupValue: widget.settings.themeMode,
              onChanged: (value) => setTheme(value, context),
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                  I18n.of(context).settingsAppSettingsAppearanceThemeLight),
              value: ThemeMode.light,
              groupValue: widget.settings.themeMode,
              onChanged: (value) => setTheme(value, context),
            ),
          ],
        ),
      ),
    );
  }

  void setTheme(ThemeMode value, BuildContext context) {
    setState(() {
      widget.settings.themeMode = value;
    });
    context.read(themeStateNotifierProvider).changeTheme(value);
  }
}
