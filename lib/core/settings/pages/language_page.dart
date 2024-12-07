// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../data/settings_providers.dart';
import '../widgets/settings_page_scaffold.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);

    final supportedLanguages = ref.watch(supportedLanguagesProvider)
      ..sort((a, b) => a.name.compareTo(b.name));

    return ConditionalParentWidget(
      condition: !SettingsPageScope.of(context).options.dense,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.language.language').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: supportedLanguages.length,
          itemBuilder: (context, index) {
            final e = supportedLanguages[index].name;

            return RadioListTile(
              activeColor: context.colorScheme.primary,
              groupValue: settings.language,
              value: e,
              title: Text(e),
              onChanged: (value) {
                if (value == null) return;
                final locale = supportedLanguages
                    .firstWhereOrNull(
                      (element) => element.name == value,
                    )
                    ?.locale;
                notifer.updateSettings(settings.copyWith(language: value));
                context.setLocaleFromString(locale);
              },
            );
          },
        ),
      ),
    );
  }
}
