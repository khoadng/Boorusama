// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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
    this.backgroundColor,
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
  final Color? backgroundColor;

  final Booru booru;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: backgroundColor,
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
              Text(
                'Advanced options (optional)',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              CreateBooruLoginField(
                text: initialLogin,
                labelText: 'booru.login_name_label'.tr(),
                hintText: 'e.g: my_login',
                onChanged: onLoginChanged,
              ),
              const SizedBox(height: 16),
              CreateBooruApiKeyField(
                text: initialApiKey,
                hintText: 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
                onChanged: onApiKeyChanged,
              ),
              const SizedBox(height: 8),
              Text(
                '*Log in to your account on the browser, visit My Account > API Key. Copy your key or create a new one if needed, ensuring all permissions are enabled for proper app functionality.',
                style: context.textTheme.titleSmall!.copyWith(
                  color: context.theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
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
                  subtitle: Text(
                    'Hide poor quality images. There might be cases where images of good enough quality slip through, so you may want to leave this option disabled.',
                    style: context.textTheme.titleSmall!.copyWith(
                      color: context.theme.hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  )),
              CreateBooruSubmitButton(onSubmit: onSubmit),
            ],
          ),
        ),
      ],
    );
  }
}
