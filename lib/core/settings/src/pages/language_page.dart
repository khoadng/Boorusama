// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
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
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);

    return ConditionalParentWidget(
      condition: !SettingsPageScope.of(context).options.dense,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.language.language').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ref
            .watch(supportedLanguagesProvider)
            .when(
              data: (supportedLanguages) => ListView.builder(
                itemCount: supportedLanguages.length,
                itemBuilder: (context, index) {
                  final e = supportedLanguages[index].name;

                  return RadioListTile(
                    activeColor: Theme.of(context).colorScheme.primary,
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
                      notifer.updateSettings(
                        settings.copyWith(language: value),
                      );
                      context.setLocaleFromString(locale);
                    },
                  );
                },
              ),
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
