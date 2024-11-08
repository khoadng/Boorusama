// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/widgets/widgets.dart';

class SettingsPageScaffold extends StatelessWidget {
  const SettingsPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  final List<Widget> children;
  final Widget title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = SettingsPageScope.of(context).options;

    return ConditionalParentWidget(
      condition: !options.dense,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: title,
        ),
        body: child,
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Theme(
            data: theme.copyWith(
              listTileTheme: theme.listTileTheme.copyWith(
                contentPadding: EdgeInsets.zero,
              ),
            ),
            child: ListView(
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
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
