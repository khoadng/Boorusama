// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../core/widgets/widgets.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_page_scaffold.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguageString = ref.watch(
      settingsProvider.select((s) => s.language),
    );
    final notifer = ref.watch(settingsNotifierProvider.notifier);

    return ConditionalParentWidget(
      condition: !SettingsPageScope.of(context).options.dense,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: Text(context.t.settings.language.language),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ref
            .watch(supportedLanguagesProvider)
            .when(
              data: (supportedLanguages) {
                final selectedLanguage = findLanguageByNameOrLocale(
                  supportedLanguages,
                  selectedLanguageString,
                );

                return ListView.builder(
                  itemCount: supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language = supportedLanguages[index];

                    return RadioListTile(
                      activeColor: Theme.of(context).colorScheme.primary,
                      groupValue: selectedLanguage,
                      value: language,
                      title: Text(language.name),
                      onChanged: (value) {
                        if (value == null) return;
                        final settings = ref.read(settingsProvider);

                        notifer.updateSettings(
                          settings.copyWith(language: value.locale),
                        );
                        context.setLocaleLanguage(value);
                      },
                    );
                  },
                );
              },
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
      ),
    );
  }
}
