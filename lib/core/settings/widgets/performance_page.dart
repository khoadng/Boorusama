// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class PerformancePage extends ConsumerStatefulWidget {
  const PerformancePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends ConsumerState<PerformancePage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.performance.performance').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            SettingsTile(
              title: const Text('settings.performance.posts_per_page').tr(),
              subtitle: Text(
                'settings.performance.posts_per_page_explain',
                style: TextStyle(
                  color: context.theme.hintColor,
                ),
              ).tr(),
              selectedOption: settings.postsPerPage,
              items: getPostsPerPagePossibleValue(),
              onChanged: (newValue) {
                ref.updateSettings(settings.copyWith(postsPerPage: newValue));
              },
              optionBuilder: (value) => Text(
                value.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
