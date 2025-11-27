// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../auth/widgets.dart';
import '../../../network/widgets.dart';
import 'booru_url_field.dart';
import 'create_booru_config_name_field.dart';
import 'unknown_booru_submit_button.dart';

class DefaultUnknownBooruWidgets extends StatelessWidget {
  const DefaultUnknownBooruWidgets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const UnknownBooruWidgetsBuilder(
      httpProtocolField: HttpProtocolOptionTile(),
      loginField: DefaultBooruLoginField(),
      apiKeyField: DefaultBooruApiKeyField(),
    );
  }
}

class AnonUnknownBooruWidgets extends StatelessWidget {
  const AnonUnknownBooruWidgets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const UnknownBooruWidgetsBuilder(
      httpProtocolField: HttpProtocolOptionTile(),
    );
  }
}

class UnknownBooruWidgetsBuilder extends StatelessWidget {
  const UnknownBooruWidgetsBuilder({
    super.key,
    this.urlField,
    this.loginField,
    this.apiKeyField,
    this.httpProtocolField,
    this.submitButton,
    this.credentialsNeeded = false,
  });

  final Widget? urlField;
  final Widget? loginField;
  final Widget? apiKeyField;
  final Widget? httpProtocolField;
  final Widget? submitButton;
  final bool credentialsNeeded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCredentialFields = loginField != null || apiKeyField != null;
    final hasAdvancedOptions = hasCredentialFields || httpProtocolField != null;

    return Column(
      children: [
        const BooruConfigNameField(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              urlField ?? const BooruUrlField(),
              const SizedBox(height: 16),
              if (hasAdvancedOptions) ...[
                if (!credentialsNeeded) ...[
                  Text(
                    'Advanced options',
                    style: theme.textTheme.titleMedium,
                  ),
                  const DefaultBooruInstructionText(
                    '*These options only be used if the site allows it.',
                  ),
                  const SizedBox(height: 16),
                ],
                if (httpProtocolField case final Widget field) ...[
                  field,
                  const SizedBox(height: 16),
                ],
                if (loginField case final Widget field) ...[
                  field,
                  const SizedBox(height: 16),
                ],
                if (apiKeyField case final Widget field) ...[
                  field,
                  const SizedBox(height: 16),
                ],
              ],
              submitButton ?? const UnknownBooruSubmitButton(),
            ],
          ),
        ),
      ],
    );
  }
}
