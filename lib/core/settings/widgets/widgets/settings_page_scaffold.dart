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
    final theme = Theme.of(context);

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
            constraints: const BoxConstraints(
              maxWidth: 700,
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
      ),
    );
  }
}
