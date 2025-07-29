// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../widgets/widgets.dart';

class SettingsPageScaffold extends StatelessWidget {
  const SettingsPageScaffold({
    required this.title,
    required this.children,
    super.key,
    this.padding,
  });

  final List<Widget> children;
  final Widget title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = SettingsPageScope.maybeOf(context)?.options;
    final hasAppBar = !(options?.dense ?? false);

    return ConditionalParentWidget(
      condition: hasAppBar,
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
              padding:
                  padding ??
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

class SettingEntry {
  const SettingEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.name,
  });

  final String id;
  final String title;
  final Widget content;
  final IconData icon;
  final String name;
}

// This should be always constant
class SettingsPageOptions {
  const SettingsPageOptions({
    required this.showIcon,
    required this.dense,
    required this.entries,
  });

  final bool showIcon;
  final bool dense;
  final List<SettingEntry> entries;
}

class SettingsPageDynamicOptions extends Equatable {
  const SettingsPageDynamicOptions({
    this.scrollTo,
  });

  final String? scrollTo;

  @override
  List<Object?> get props => [scrollTo];
}

class SettingsPageDynamicScope extends InheritedWidget {
  const SettingsPageDynamicScope({
    required this.options,
    required super.child,
    super.key,
  });

  static SettingsPageDynamicScope of(BuildContext context) {
    final item = context
        .dependOnInheritedWidgetOfExactType<SettingsPageDynamicScope>();

    if (item == null) {
      throw FlutterError(
        'SettingsPageDynamicScope.of was called with a context that '
        'does not contain a SettingsPageDynamicScope.',
      );
    }

    return item;
  }

  final SettingsPageDynamicOptions options;

  @override
  bool updateShouldNotify(SettingsPageDynamicScope oldWidget) {
    return options != oldWidget.options;
  }
}

class SettingsPageScope extends InheritedWidget {
  const SettingsPageScope({
    required this.options,
    required super.child,
    super.key,
  });

  static SettingsPageScope of(BuildContext context) {
    final item = context
        .dependOnInheritedWidgetOfExactType<SettingsPageScope>();

    if (item == null) {
      throw FlutterError(
        'SettingsPageScope.of was called with a context that '
        'does not contain a SettingsPageScope.',
      );
    }

    return item;
  }

  static SettingsPageScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsPageScope>();
  }

  final SettingsPageOptions options;

  @override
  bool updateShouldNotify(SettingsPageScope oldWidget) {
    return options != oldWidget.options;
  }
}
