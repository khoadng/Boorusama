// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'package:boorusama/i18n.dart';
import 'widgets/settings_tile.dart';

class GeneralPage extends ConsumerStatefulWidget {
  const GeneralPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends ConsumerState<GeneralPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.general').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            SettingsTile<BooruType>(
              title: const Text('settings.general_data_source').tr(),
              selectedOption:
                  settings.safeMode ? BooruType.safebooru : BooruType.danbooru,
              items: [...BooruType.values]
                ..remove(BooruType.testbooru)
                ..remove(BooruType.unknown),
              onChanged: (value) => ref.updateSettings(
                  settings.copyWith(safeMode: value == BooruType.safebooru)),
              optionBuilder: (value) => Text(value.name.sentenceCase),
            ),
          ],
        ),
      ),
    );
  }
}
