// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/widgets/widgets.dart';

class SettingsPageScaffold extends StatelessWidget {
  const SettingsPageScaffold({
    super.key,
    required this.title,
    this.hasAppBar = true,
    required this.children,
    this.padding,
  });

  final List<Widget> children;
  final Widget title;
  final bool hasAppBar;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: title,
        ),
        body: child,
      ),
      child: SafeArea(
        child: Center(
          heightFactor: 1,
          child: Container(
            padding: padding,
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: ListView(
              shrinkWrap: true,
              primary: false,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
