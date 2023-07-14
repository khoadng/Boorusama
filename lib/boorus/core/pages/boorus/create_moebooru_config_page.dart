// Flutter imports:
import 'package:flutter/material.dart';

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
import 'widgets/create_booru_config_name_field.dart';

class CreateMoebooruConfigPage extends StatefulWidget {
  const CreateMoebooruConfigPage({
    super.key,
    required this.onLoginChanged,
    required this.onHashedPasswordChanged,
    required this.onConfigNameChanged,
    required this.onRatingFilterChanged,
    required this.onSubmit,
    required this.booru,
    required this.booruFactory,
    this.initialLogin,
    this.initialHashedPassword,
    this.initialConfigName,
    this.initialRatingFilter,
  });

  final String? initialLogin;
  final String? initialHashedPassword;
  final String? initialConfigName;
  final BooruConfigRatingFilter? initialRatingFilter;

  final BooruFactory booruFactory;
  final void Function(String value) onLoginChanged;
  final void Function(String value) onHashedPasswordChanged;
  final void Function(String value) onConfigNameChanged;
  final void Function(BooruConfigRatingFilter? value) onRatingFilterChanged;
  final void Function()? onSubmit;

  final Booru booru;

  @override
  State<CreateMoebooruConfigPage> createState() =>
      _CreateMoebooruConfigPageState();
}

class _CreateMoebooruConfigPageState extends State<CreateMoebooruConfigPage> {
  late var hashedPassword = widget.initialHashedPassword ?? '';
  var password = '';

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      booru: widget.booru,
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
                text: widget.initialConfigName,
                onChanged: widget.onConfigNameChanged,
              ),
              const SizedBox(height: 16),
              CreateBooruLoginField(
                hintText: 'my_login',
                text: widget.initialLogin,
                onChanged: widget.onLoginChanged,
                labelText: 'booru.login_name_label'.tr(),
              ),
              const SizedBox(height: 16),
              CreateBooruPasswordField(
                onChanged: (value) => setState(() {
                  if (value.isEmpty) {
                    hashedPassword = '';
                    widget.onHashedPasswordChanged('');
                    return;
                  }

                  password = value;
                  hashedPassword = hashBooruPasswordSHA1(
                    booru: widget.booru,
                    booruFactory: widget.booruFactory,
                    password: value,
                  );
                  widget.onHashedPasswordChanged(hashedPassword);
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
                value: widget.initialRatingFilter,
                onChanged: widget.onRatingFilterChanged,
              ),
              const SizedBox(height: 16),
              CreateBooruSubmitButton(onSubmit: widget.onSubmit),
            ],
          ),
        ),
      ],
    );
  }
}
