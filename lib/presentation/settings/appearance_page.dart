import 'package:boorusama/application/themes/bloc/theme_bloc.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppearancePage extends StatefulWidget {
  AppearancePage({Key key}) : super(key: key);

  @override
  _AppearancePageState createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  ISettingRepository _settingRepository;
  Setting _setting = Setting.defaultSettings;

  @override
  void initState() {
    super.initState();
    _settingRepository = Provider.of<SettingRepository>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final setting = await _settingRepository.load();
      setState(() {
        _setting = setting;
      });
    });
  }

  @override
  void dispose() {
    _settingRepository.save(_setting);
    super.dispose();
  }

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
              groupValue: _setting.themeMode,
              onChanged: (value) => setTheme(value, context),
            ),
            RadioListTile<ThemeMode>(
              title: const Text("Light"),
              value: ThemeMode.light,
              groupValue: _setting.themeMode,
              onChanged: (value) => setTheme(value, context),
            ),
          ],
        ),
      ),
    );
  }

  void setTheme(ThemeMode value, BuildContext context) {
    setState(() {
      _setting.themeMode = value;
    });
    context.read<ThemeBloc>().add(ThemeChanged(theme: value));
  }
}
