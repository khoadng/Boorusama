// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateE621ConfigPage extends ConsumerStatefulWidget {
  const CreateE621ConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
  });

  final Color? backgroundColor;
  final BooruConfig config;

  @override
  ConsumerState<CreateE621ConfigPage> createState() =>
      _CreateDanbooruConfigPageState();
}

class _CreateDanbooruConfigPageState
    extends ConsumerState<CreateE621ConfigPage> {
  late var login = widget.config.login ?? '';
  late var apiKey = widget.config.apiKey ?? '';
  late var configName = widget.config.name;
  late var ratingFilter = widget.config.ratingFilter;
  late var hideDeleted =
      widget.config.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: widget.backgroundColor,
      booruType: widget.config.booruType,
      url: widget.config.url,
      isUnknown: widget.config.isUnverified(),
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
                text: configName,
                onChanged: (value) => setState(() => configName = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Advanced options (optional)',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              CreateBooruLoginField(
                text: login,
                labelText: 'booru.login_name_label'.tr(),
                hintText: 'e.g: my_login',
                onChanged: (value) => setState(() => login = value),
              ),
              const SizedBox(height: 16),
              CreateBooruApiKeyField(
                text: apiKey,
                hintText: 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
                onChanged: (value) => setState(() => apiKey = value),
              ),
              const SizedBox(height: 8),
              CreateBooruRatingOptionsTile(
                value: ratingFilter,
                onChanged: (value) =>
                    value != null ? setState(() => ratingFilter = value) : null,
              ),
              CreateBooruSubmitButton(onSubmit: allowSubmit() ? submit : null),
            ],
          ),
        ),
      ],
    );
  }

  void submit() {
    final config = AddNewBooruConfig(
      login: login,
      apiKey: apiKey,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: configName,
      hideDeleted: hideDeleted,
      ratingFilter: ratingFilter,
      url: widget.config.url,
      customDownloadFileNameFormat: null,
      customBulkDownloadFileNameFormat: null,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.navigator.pop();
  }

  bool allowSubmit() {
    if (configName.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
  }
}
