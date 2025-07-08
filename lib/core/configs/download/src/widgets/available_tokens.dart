// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../../foundation/platform.dart';
import '../../../../../foundation/toast.dart';
import '../../../../downloads/filename/types.dart';
import 'token_option_help_modal.dart';

class AvailableTokens extends ConsumerWidget {
  const AvailableTokens({
    required this.downloadFilenameBuilder,
    super.key,
  });

  final DownloadFilenameGenerator? downloadFilenameBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableTokens = downloadFilenameBuilder?.availableTokens ?? {};

    return Wrap(
      runSpacing: isDesktopPlatform() ? 4 : -4,
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Available tokens: '.hc),
        for (final token in availableTokens)
          RawChip(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            visualDensity: VisualDensity.compact,
            label: Text(token),
            onPressed: () {
              final tokenOptions = downloadFilenameBuilder?.getTokenOptions(
                token,
              );

              if (tokenOptions == null) {
                showErrorToast(context, 'Token $token is not available'.hc);
                return;
              }

              showAdaptiveBottomSheet(
                context,
                settings: const RouteSettings(name: 'download_token_options'),
                builder: (context) => TokenOptionHelpModal(
                  token: token,
                  tokenOptions: tokenOptions,
                  downloadFilenameBuilder: downloadFilenameBuilder,
                ),
              );
            },
          ),
      ],
    );
  }
}
