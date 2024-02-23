// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_passworld_field.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/crypto.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateMoebooruConfigPage extends ConsumerStatefulWidget {
  const CreateMoebooruConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
  });

  final BooruConfig config;

  final Color? backgroundColor;

  @override
  ConsumerState<CreateMoebooruConfigPage> createState() =>
      _CreateMoebooruConfigPageState();
}

class _CreateMoebooruConfigPageState
    extends ConsumerState<CreateMoebooruConfigPage> {
  late var login = widget.config.login ?? '';
  late var apiKey = widget.config.apiKey ?? '';
  late var hashedPassword = widget.config.apiKey ?? '';
  var password = '';

  final passwordController = TextEditingController();

  BooruFactory get booruFactory => ref.read(booruFactoryProvider);

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      backgroundColor: widget.backgroundColor,
      config: widget.config,
      authTabBuilder: (context) => _buildAuthTab(),
      hasDownloadTab: true,
      hasRatingFilter: true,
      tabsBuilder: (context) => {},
      allowSubmit: allowSubmit,
      submit: submit,
    );
  }

  Widget _buildAuthTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          CreateBooruLoginField(
            hintText: 'my_login',
            text: login,
            onChanged: (value) => setState(() => login = value),
            labelText: 'booru.login_name_label'.tr(),
          ),
          const SizedBox(height: 16),
          CreateBooruPasswordField(
            controller: passwordController,
            onChanged: (value) => setState(() {
              if (value.isEmpty) {
                hashedPassword = '';
                setState(() => apiKey = value);
                return;
              }

              password = value;
              hashedPassword = hashBooruPasswordSHA1(
                url: widget.config.url,
                booru: widget.config.createBooruFrom(booruFactory),
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
                  IconButton(
                    splashRadius: 12,
                    onPressed: () =>
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        password = '';
                        hashedPassword = '';
                        apiKey = '';

                        passwordController.clear();
                      });
                    }),
                    icon: const Icon(Symbols.close),
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
        ],
      ),
    );
  }

  void submit(CreateConfigData data) {
    final config = AddNewBooruConfig(
      login: login,
      apiKey: apiKey,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: data.configName,
      hideDeleted: false,
      ratingFilter: data.ratingFilter ?? BooruConfigRatingFilter.none,
      url: widget.config.url,
      customDownloadFileNameFormat: data.customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: data.customBulkDownloadFileNameFormat,
      imageDetaisQuality: data.imageDetaisQuality,
      granularRatingFilters: data.granularRatingFilters,
      postGestures: data.postGestures,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.navigator.pop();
  }

  bool allowSubmit(CreateConfigData data) {
    if (data.configName.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
  }
}
