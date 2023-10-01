// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';

class CreatePhilomenaConfigPage extends ConsumerStatefulWidget {
  const CreatePhilomenaConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
  });

  final BooruConfig config;
  final Color? backgroundColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreatePhilomenaConfigPageState();
}

class _CreatePhilomenaConfigPageState
    extends ConsumerState<CreatePhilomenaConfigPage> {
  late String configName = widget.config.name;
  late String key = widget.config.apiKey ?? '';

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: widget.backgroundColor,
      booruType: widget.config.booruType,
      url: widget.config.url,
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
              CreateBooruApiKeyField(
                text: key,
                hintText: 'e.g: AC8gZrxKsDpWy3unU0jB',
                onChanged: (value) => setState(() => key = value),
              ),
              const SizedBox(height: 8),
              Text(
                '*You can find your authentication token in your account settings in the browser',
                style: context.textTheme.titleSmall!.copyWith(
                  color: context.theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              CreateBooruSubmitButton(
                onSubmit: allowSubmit() ? submit : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool allowSubmit() {
    return configName.isNotEmpty;
  }

  void submit() {
    ref.read(booruConfigProvider.notifier).addFromAddBooruConfig(
          newConfig: AddNewBooruConfig(
            login: '',
            apiKey: key,
            booru: widget.config.booruType,
            booruHint: widget.config.booruType,
            configName: configName,
            hideDeleted: false,
            ratingFilter: BooruConfigRatingFilter.none,
            url: widget.config.url,
          ),
        );
    context.pop();
  }
}
