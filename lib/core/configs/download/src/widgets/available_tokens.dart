// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
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
    final availableTokens =
        downloadFilenameBuilder?.availableTokens ?? <TokenInfo>{};

    return Wrap(
      runSpacing: ref.watch(appPlatformProvider).isDesktop ? 4 : -4,
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          context.t.booru.downloads.filename.available_tokens,
        ),
        for (final token in availableTokens)
          KurumiMaterialRawChip(
            backgroundColor: Kurumi.themeOf(
              context,
            ).colorScheme.secondaryContainer,
            visualDensity: VisualDensity.compact,
            label: Text(token.name),
            avatar: token.type == TokenType.async
                ? const Icon(
                    Icons.access_time,
                  )
                : null,
            onPressed: () {
              final tokenOptions = downloadFilenameBuilder?.getTokenOptions(
                token.name,
              );

              if (tokenOptions == null) {
                Kurumi.showErrorToast(
                  context,
                  context.t.booru.downloads.filename.no_token_error(
                    token: token.name,
                  ),
                );
                return;
              }

              Kurumi.showAdaptiveBottomSheet(
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
