import 'package:boorusama/application/themes/bloc/theme_bloc.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: Text("Appearance"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text("Theme"),
            RadioListTile<ThemeMode>(
              title: const Text("Dark"),
              value: ThemeMode.dark,
              groupValue: widget.settings.themeMode,
              onChanged: (value) => setTheme(value, context),
            ),
            RadioListTile<ThemeMode>(
              title: const Text("Light"),
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
    context.read<ThemeBloc>().add(ThemeChanged(theme: value));
  }
}
