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

class TokenOptionHelpModal extends StatelessWidget {
  const TokenOptionHelpModal({
    required this.token,
    required this.tokenOptions,
    required this.downloadFilenameBuilder,
    super.key,
  });

  final String token;
  final List<String> tokenOptions;
  final DownloadFilenameGenerator<Post>? downloadFilenameBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available options'.hc),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Symbols.close),
          ),
        ],
      ),
      body: tokenOptions.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    token,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    itemCount: tokenOptions.length,
                    itemBuilder: (context, index) {
                      final option = tokenOptions[index];
                      final docs = downloadFilenameBuilder
                          ?.getDocsForTokenOption(token, option);

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
                  ),
                ),
              ],
            )
          : const Center(
              child: Text('No options available'),
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
