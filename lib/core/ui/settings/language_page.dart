// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final supportedLanguages = ref.watch(supportedLanguagesProvider);

    return ConditionalParentWidget(
      condition: hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.language.language').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: Column(
          children: supportedLanguages
              .map((e) => e.name)
              .map(
                (e) => RadioListTile<String>(
                  activeColor: Theme.of(context).colorScheme.primary,
                  groupValue: settings.language,
                  value: e,
                  title: Text(e),
                  onChanged: (value) {
                    if (value == null) return;
                    final locale = supportedLanguages
                        .firstWhere(
                          (element) => element.name == value,
                        )
                        .locale;
                    ref.updateSettings(settings.copyWith(language: value));
                    final data = locale.split('-');

                    context.setLocale(Locale(data[0], data[1]));
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
