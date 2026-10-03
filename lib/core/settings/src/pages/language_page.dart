// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
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
    final supportedLanguages = ref.watch(supportedLanguagesProvider);
    final selectedLanguage = findLanguageByNameOrLocale(
      supportedLanguages,
      selectedLanguageString,
    );

    return KurumiRadioGroup(
      groupValue: selectedLanguage,
      onChanged: (value) {
        if (value == null) return;
        final settings = ref.read(settingsProvider);

        notifer.updateSettings(
          settings.copyWith(language: value.locale),
        );
        context.setLocaleLanguage(value);
      },
      child: SettingsPageScaffold(
        title: Text(context.t.settings.language.language),
        children: [
          for (final language in supportedLanguages)
            RadioListTile(
              activeColor: Kurumi.themeOf(context).colorScheme.primary,
              value: language,
              title: Text(language.name),
            ),
        ],
      ),
    );
  }
}
