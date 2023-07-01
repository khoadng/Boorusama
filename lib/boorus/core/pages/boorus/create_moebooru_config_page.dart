// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_passworld_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/create_booru_config_name_field.dart';
import 'widgets/create_booru_header.dart';
import 'widgets/create_booru_site_url_field.dart';
import 'widgets/selected_booru_chip.dart';

class CreateMoebooruConfigPage extends StatelessWidget {
  const CreateMoebooruConfigPage({
    super.key,
    required this.onLoginChanged,
    required this.onApiKeyChanged,
    required this.onConfigNameChanged,
    required this.onRatingFilterChanged,
    required this.onSubmit,
    required this.booru,
    this.initialSiteUrl,
    this.initialLogin,
    this.initialApiKey,
    this.initialConfigName,
    this.initialRatingFilter,
    this.hasHeader = true,
  });

  final String? initialSiteUrl;
  final String? initialLogin;
  final String? initialApiKey;
  final String? initialConfigName;
  final BooruConfigRatingFilter? initialRatingFilter;
  final bool hasHeader;

  final void Function(String value) onLoginChanged;
  final void Function(String value) onApiKeyChanged;
  final void Function(String value) onConfigNameChanged;
  final void Function(BooruConfigRatingFilter? value) onRatingFilterChanged;
  final void Function()? onSubmit;

  final Booru booru;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      children: [
        if (hasHeader) const CreateBooruTitleHeader(),
        SelectedBooruChip(
          booruType: booru.booruType,
        ),
        const SizedBox(height: 8),
        const Divider(
          thickness: 2,
          endIndent: 16,
          indent: 16,
        ),
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
              CreateBooruSiteUrlField(
                text: initialSiteUrl,
              ),
              const SizedBox(height: 16),
              CreateBooruLoginField(
                text: initialLogin,
                onChanged: onLoginChanged,
                labelText: 'booru.login_name_label'.tr(),
              ),
              const SizedBox(height: 16),
              CreateBooruPasswordField(
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
