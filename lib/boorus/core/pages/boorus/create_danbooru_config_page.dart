// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/create_booru_config_name_field.dart';
import 'widgets/create_booru_hide_deleted_switch.dart';
import 'widgets/create_booru_login_field.dart';
import 'widgets/create_booru_rating_options_tile.dart';
import 'widgets/create_booru_submit_button.dart';

class CreateDanbooruConfigPage extends StatelessWidget {
  const CreateDanbooruConfigPage({
    super.key,
    required this.onLoginChanged,
    required this.onApiKeyChanged,
    required this.onConfigNameChanged,
    this.onRatingFilterChanged,
    required this.onHideDeletedChanged,
    required this.onSubmit,
    required this.booru,
    this.initialLogin,
    this.initialApiKey,
    this.initialConfigName,
    this.initialRatingFilter,
    this.initialHideDeleted,
  });

  final String? initialLogin;
  final String? initialApiKey;
  final String? initialConfigName;
  final BooruConfigRatingFilter? initialRatingFilter;
  final bool? initialHideDeleted;

  final void Function(String value) onLoginChanged;
  final void Function(String value) onApiKeyChanged;
  final void Function(String value) onConfigNameChanged;
  final void Function(BooruConfigRatingFilter? value)? onRatingFilterChanged;
  final void Function(bool value) onHideDeletedChanged;
  final void Function()? onSubmit;

  final Booru booru;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      booru: booru,
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
                labelText: 'booru.login_name_label'.tr(),
                hintText: 'my_login',
                onChanged: onLoginChanged,
              ),
              const SizedBox(height: 16),
              CreateBooruApiKeyField(
                text: initialApiKey,
                hintText: 'o6H5u8QrxC7dN3KvF9D2bM4p',
                onChanged: onApiKeyChanged,
              ),
              if (onRatingFilterChanged != null) const SizedBox(height: 16),
              if (onRatingFilterChanged != null)
                CreateBooruRatingOptionsTile(
                  value: initialRatingFilter,
                  onChanged: onRatingFilterChanged!,
                ),
              const SizedBox(height: 16),
              CreateBooruHideDeletedSwitch(
                value: initialHideDeleted,
                onChanged: onHideDeletedChanged,
              ),
              CreateBooruSubmitButton(onSubmit: onSubmit),
            ],
          ),
        ),
      ],
    );
  }
}
