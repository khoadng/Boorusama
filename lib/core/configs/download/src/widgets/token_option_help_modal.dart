// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filename_generator/filename_generator.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../downloads/filename/types.dart';
import '../../../../posts/post/post.dart';
import '../../../../widgets/compact_chip.dart';
import '../../../../widgets/info_container.dart';

class TokenOptionHelpModal extends StatelessWidget {
  const TokenOptionHelpModal({
    required this.token,
    required this.tokenOptions,
    required this.downloadFilenameBuilder,
    super.key,
  });

  final TokenInfo token;
  final List<String> tokenOptions;
  final DownloadFilenameGenerator<Post>? downloadFilenameBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.booru.downloads.filename.available_token_options),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Symbols.close),
          ),
        ],
      ),
      body: tokenOptions.isNotEmpty
          ? CustomScrollView(
              slivers: [
                if (token.type == TokenType.async)
                  SliverToBoxAdapter(
                    child: WarningContainer(
                      title: context.t.generic.warning,
                      contentBuilder: (_) => Text(
                        context.t.booru.downloads.filename.slow_token_warning,
                      ),
                    ),
                  ),
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: false,
                  toolbarHeight: kToolbarHeight * 0.8,
                  title: Text(
                    token.name,
                    style: textTheme.titleLarge,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final option = tokenOptions[index];
                      final docs = downloadFilenameBuilder
                          ?.getDocsForTokenOption(token.name, option);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        title: Row(
                          children: [
                            Flexible(child: Text(option)),
                            const SizedBox(width: 8),
                            switch (docs?.tokenOption) {
                              IntegerTokenOption _ => _buildOptionChip(
                                context,
                                'integer',
                              ),
                              BooleanTokenOption _ => _buildOptionChip(
                                context,
                                'boolean',
                              ),
                              StringTokenOption _ => _buildOptionChip(
                                context,
                                'string',
                              ),
                              _ => const SizedBox.shrink(),
                            },
                          ],
                        ),
                        subtitle: docs != null
                            ? Container(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(docs.description),
                              )
                            : null,
                        trailing: IconButton(
                          onPressed: () {
                            AppClipboard.copyWithDefaultToast(context, option);
                          },
                          icon: const Icon(Symbols.copy_all),
                        ),
                      );
                    },
                    childCount: tokenOptions.length,
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                context.t.booru.downloads.filename.no_options_available,
              ),
            ),
    );
  }

  Widget _buildOptionChip(BuildContext context, String label) {
    return CompactChip(
      label: label,
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
    );
  }
}
