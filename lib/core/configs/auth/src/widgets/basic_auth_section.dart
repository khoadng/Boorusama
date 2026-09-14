// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../foundation/url_launcher.dart';
import '../../widgets.dart';

class BasicAuthSection extends ConsumerWidget {
  const BasicAuthSection({
    required this.loginController,
    required this.apiKeyController,
    required this.loginField,
    required this.apiKeyField,
    required this.instructionsText,
    required this.titleText,
    required this.descriptionText,
    super.key,
    this.apiKeyUrl,
    this.pasteButton,
    this.verifyButton,
  });

  final TextEditingController loginController;
  final TextEditingController apiKeyController;
  final Widget loginField;
  final Widget apiKeyField;
  final String instructionsText;
  final String? titleText;
  final String? descriptionText;
  final String? apiKeyUrl;
  final Widget? pasteButton;
  final Widget? verifyButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Kurumi.themeOf(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (titleText case final text?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.hintColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ?verifyButton,
              ],
            ),
          ),
        if (descriptionText case final desc?)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              desc,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.hintColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        const SizedBox(height: 12),
        loginField,
        const SizedBox(height: 16),
        apiKeyField,
        const SizedBox(height: 8),
        DefaultBooruInstructionHtmlText(
          instructionsText,
          onApiLinkTap: apiKeyUrl != null
              ? () => launchExternalUrlString(
                  apiKeyUrl!,
                  launcher: ref.read(externalUrlLauncherProvider),
                )
              : null,
        ),
        if (pasteButton case final button?) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              button,
            ],
          ),
        ],
      ],
    );
  }
}
