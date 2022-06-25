// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    Key? key,
    required this.title,
    required this.selectedOption,
    required this.onTap,
    required this.leading,
  }) : super(key: key);

  final Widget title;
  final String selectedOption;
  final VoidCallback onTap;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedOption),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: FaIcon(
              FontAwesomeIcons.angleDown,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
