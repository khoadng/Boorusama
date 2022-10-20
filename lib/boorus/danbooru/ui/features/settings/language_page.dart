// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';

final languages = {
  'en': 'english',
  'vi': 'vietnamese',
  'ru': 'russian',
  'be': 'belarusian',
};

String getLanguageText(String value) {
  return 'settings.language.${languages[value]}';
}

class LanguagePage extends StatelessWidget {
  const LanguagePage({
    Key? key,
    this.hasAppBar = true,
  }) : super(key: key);

  final bool hasAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.language != current.settings.language,
      builder: (context, state) {
        return Scaffold(
          appBar: hasAppBar
              ? AppBar(
                  title: const Text('settings.language.language').tr(),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: languages.keys
                  .map(
                    (e) => RadioListTile<String>(
                      activeColor: Theme.of(context).colorScheme.primary,
                      groupValue: state.settings.language,
                      value: e,
                      title: Text(getLanguageText(e).tr()),
                      onChanged: (value) {
                        if (value == null) return;
                        context
                            .read<SettingsCubit>()
                            .update(state.settings.copyWith(language: value));
                        context.setLocale(Locale(value));
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
