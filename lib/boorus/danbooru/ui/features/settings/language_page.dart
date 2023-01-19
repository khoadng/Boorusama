// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

final languages = {
  'en': 'english',
  'vi': 'vietnamese',
  'ru': 'russian',
  'be': 'belarusian',
  'ja': 'japanese',
};

String getLanguageText(String value) {
  return 'settings.language.${languages[value]}';
}

class LanguagePage extends StatelessWidget {
  const LanguagePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context) {
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

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
          children: languages.keys
              .map(
                (e) => RadioListTile<String>(
                  activeColor: Theme.of(context).colorScheme.primary,
                  groupValue: settings.language,
                  value: e,
                  title: Text(getLanguageText(e).tr()),
                  onChanged: (value) {
                    if (value == null) return;
                    context
                        .read<SettingsCubit>()
                        .update(settings.copyWith(language: value));
                    context.setLocale(Locale(value));
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
