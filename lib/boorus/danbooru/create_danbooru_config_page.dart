// Flutter imports:
import 'package:boorusama/flutter.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/pages/boorus/widgets/create_booru_config_name_field.dart';
import '../core/pages/boorus/widgets/create_booru_hide_deleted_switch.dart';
import '../core/pages/boorus/widgets/create_booru_login_field.dart';
import '../core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import '../core/pages/boorus/widgets/create_booru_submit_button.dart';

class CreateDanbooruConfigPage extends ConsumerStatefulWidget {
  const CreateDanbooruConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
  });

  final Color? backgroundColor;
  final BooruConfig config;

  @override
  ConsumerState<CreateDanbooruConfigPage> createState() =>
      _CreateDanbooruConfigPageState();
}

class _CreateDanbooruConfigPageState
    extends ConsumerState<CreateDanbooruConfigPage> {
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
              Text(
                '*Log in to your account on the browser, visit My Account > API Key. Copy your key or create a new one if needed, ensuring all permissions are enabled for proper app functionality.',
                style: context.textTheme.titleSmall!.copyWith(
                  color: context.theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              CreateBooruRatingOptionsTile(
                value: ratingFilter,
                onChanged: (value) =>
                    value != null ? setState(() => ratingFilter = value) : null,
              ),
              const SizedBox(height: 16),
              CreateBooruHideDeletedSwitch(
                  value: hideDeleted,
                  onChanged: (value) => setState(() => hideDeleted = value),
                  subtitle: Text(
                    'Hide low-quality images, some decent ones might also be hidden.',
                    style: context.textTheme.titleSmall!.copyWith(
                      color: context.theme.hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  )),
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
