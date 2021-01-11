import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/presentation/settings/appearance_page.dart';
import 'package:boorusama/presentation/settings/tag_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
        title: Text("Settings"),
      ),
      body: SettingsList(
        backgroundColor: Theme.of(context).appBarTheme.color,
        sections: [
          SettingsSection(
            title: "App Settings",
            tiles: [
              SettingsTile.switchTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: "Safe mode",
                  onToggle: (value) {
                    setState(() {
                      _setting.safeMode = value;
                    });
                  },
                  switchValue: _setting.safeMode),
              SettingsTile(
                leading: Icon(Icons.tag),
                title: "Blacklisted tags",
                onTap: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) => TagSettingsPage(
                  //       settings: _setting,
                  //     ),
                  //   ),
                  // );
                },
              ),
              SettingsTile(
                leading: Icon(Icons.format_paint),
                title: "Appearance",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => AppearancePage(
                        settings: _setting,
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
