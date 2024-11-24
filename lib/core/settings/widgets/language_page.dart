// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
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
                ref.updateSettings(settings.copyWith(language: value));
                context.setLocaleFromString(locale);
              },
            );
          },
        ),
      ),
    );
  }
}
