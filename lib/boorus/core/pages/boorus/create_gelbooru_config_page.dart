// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'widgets/create_booru_config_name_field.dart';

class CreateGelbooruConfigPage extends StatelessWidget {
  const CreateGelbooruConfigPage({
    super.key,
    required this.onLoginChanged,
    required this.onApiKeyChanged,
    required this.onConfigNameChanged,
    required this.onRatingFilterChanged,
    required this.onSubmit,
    required this.booruType,
    required this.url,
    this.initialLogin,
    this.initialApiKey,
    this.initialConfigName,
    this.initialRatingFilter,
    this.backgroundColor,
    this.isUnkown = false,
  });

  final String? initialLogin;
  final String? initialApiKey;
  final String? initialConfigName;
  final BooruConfigRatingFilter? initialRatingFilter;

  final void Function(String value) onLoginChanged;
  final void Function(String value) onApiKeyChanged;
  final void Function(String value) onConfigNameChanged;
  final void Function(BooruConfigRatingFilter? value) onRatingFilterChanged;
  final void Function()? onSubmit;

  final Color? backgroundColor;

  final BooruType booruType;
  final String url;
  final bool isUnkown;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: backgroundColor,
      booruType: booruType,
      url: url,
      isUnknown: isUnkown,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateBooruConfigNameField(
                text: initialConfigName,
                onChanged: onConfigNameChanged,
              ),
              const SizedBox(height: 16),
              CreateBooruLoginField(
                text: initialLogin,
                onChanged: onLoginChanged,
                labelText: 'User ID',
                hintText: '1234567',
              ),
              const SizedBox(height: 16),
              CreateBooruApiKeyField(
                hintText:
                    '2e89f79b593ed40fd8641235f002221374e50d6343d3afe1687fc70decae58dcf',
                text: initialApiKey,
                onChanged: onApiKeyChanged,
              ),
              const SizedBox(height: 16),
              CreateBooruRatingOptionsTile(
                value: initialRatingFilter,
                onChanged: onRatingFilterChanged,
              ),
              const SizedBox(height: 16),
              CreateBooruSubmitButton(onSubmit: onSubmit),
            ],
          ),
        ),
      ],
    );
  }
}
