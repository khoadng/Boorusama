import 'package:boorusama/infrastructure/repositories/settings/setting.dart';
import 'package:flutter/material.dart';

class TagSettingsPage extends StatefulWidget {
  TagSettingsPage({
    Key key,
    @required this.settings,
  }) : super(key: key);

  final Setting settings;

  @override
  _TagSettingsPageState createState() => _TagSettingsPageState();
}

class _TagSettingsPageState extends State<TagSettingsPage> {
  @override
  void dispose() {
    // widget.settings.blacklistedTags = _blacklistedTags.join("\n");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blacklisted tags"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.settings.blacklistedTags.split("\n")[index]),
          );
        },
        itemCount: widget.settings.blacklistedTags.split("\n").length,
      ),
    );
  }
}
