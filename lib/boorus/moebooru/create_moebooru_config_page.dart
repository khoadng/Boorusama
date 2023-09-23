// Flutter imports:
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_passworld_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/foundation/crypto.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateMoebooruConfigPage extends ConsumerStatefulWidget {
  const CreateMoebooruConfigPage({
    super.key,
    required this.booruType,
    required this.url,
    this.isUnkown = false,
    this.initialLogin,
    this.initialHashedPassword,
    this.initialConfigName,
    this.initialRatingFilter,
    this.backgroundColor,
  });

  final String? initialLogin;
  final String? initialHashedPassword;
  final String? initialConfigName;
  final BooruConfigRatingFilter? initialRatingFilter;

  final Color? backgroundColor;

  final BooruType booruType;
  final String url;
  final bool isUnkown;

  @override
  ConsumerState<CreateMoebooruConfigPage> createState() =>
      _CreateMoebooruConfigPageState();
}

class _CreateMoebooruConfigPageState
    extends ConsumerState<CreateMoebooruConfigPage> {
  late var login = widget.initialLogin ?? '';
  late var apiKey = widget.initialHashedPassword ?? '';
  late var configName = widget.initialConfigName ?? '';
  late var ratingFilter =
      widget.initialRatingFilter ?? BooruConfigRatingFilter.none;

  late var hashedPassword = widget.initialHashedPassword ?? '';
  var password = '';

  BooruFactory get booruFactory => ref.read(booruFactoryProvider);

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: widget.backgroundColor,
      booruType: widget.booruType,
      url: widget.url,
      isUnknown: widget.isUnkown,
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
              CreateBooruLoginField(
                hintText: 'my_login',
                text: login,
                onChanged: (value) => setState(() => login = value),
                labelText: 'booru.login_name_label'.tr(),
              ),
              const SizedBox(height: 16),
              CreateBooruPasswordField(
                onChanged: (value) => setState(() {
                  if (value.isEmpty) {
                    hashedPassword = '';
                    setState(() => apiKey = value);
                    return;
                  }

                  password = value;
                  hashedPassword = hashBooruPasswordSHA1(
                    booru: booruFactory.from(type: widget.booruType),
                    booruFactory: booruFactory,
                    password: value,
                  );
                  setState(() => apiKey = hashedPassword);
                }),
              ),
              if (hashedPassword.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.hashtag,
                        size: 16,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hashedPassword,
                          style: context.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'The app will use the hashed password to authenticate with the site. Your password will not be stored.',
                style: context.textTheme.titleSmall!.copyWith(
                  color: context.theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              CreateBooruRatingOptionsTile(
                value: ratingFilter,
                onChanged: (value) =>
                    value != null ? setState(() => ratingFilter = value) : null,
              ),
              const SizedBox(height: 16),
              CreateBooruSubmitButton(onSubmit: allowSubmit() ? submit : null),
            ],
          ),
        ),
      ],
    );
  }

  void submit() {
    ref.read(booruConfigProvider.notifier).addFromAddBooruConfig(
          newConfig: AddNewBooruConfig(
            login: login,
            apiKey: apiKey,
            booru: widget.booruType,
            booruHint: widget.booruType,
            configName: configName,
            hideDeleted: false,
            ratingFilter: ratingFilter,
            url: widget.url,
          ),
        );
    context.navigator.pop();
  }

  bool allowSubmit() {
    if (configName.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
  }
}
