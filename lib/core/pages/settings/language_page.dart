// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final supportedLanguages = ref.watch(supportedLanguagesProvider)
      ..sort((a, b) => a.name.compareTo(b.name));

    return ConditionalParentWidget(
      condition: hasAppBar,
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
            return RadioListTile<String>(
              activeColor: context.colorScheme.primary,
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
            );
          },
        ),
      ),
    );
  }
}
