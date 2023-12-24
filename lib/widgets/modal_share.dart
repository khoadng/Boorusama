// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';

class ModalShare extends StatelessWidget {
  const ModalShare({
    super.key,
    required this.onTap,
    required this.onTapFile,
    required this.imagePath,
    required this.booruLink,
    required this.sourceLink,
  });

  final void Function(String value) onTap;
  final void Function(String filePath) onTapFile;
  final String booruLink;
  final String sourceLink;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sourceLink.isNotEmpty)
              ListTile(
                title: const Text('post.detail.share.source').tr(),
                leading: const Icon(Symbols.link),
                onTap: () {
                  context.navigator.pop();
                  onTap.call(sourceLink);
                },
              ),
            ListTile(
              title: const Text('post.detail.share.booru').tr(),
              leading: const Icon(Symbols.box),
              onTap: () {
                context.navigator.pop();
                onTap.call(booruLink);
              },
            ),
            if (imagePath.isNotEmpty)
              ListTile(
                title: const Text('post.detail.share.image').tr(),
                leading: const Icon(Symbols.image),
                onTap: () {
                  context.navigator.pop();
                  onTapFile.call(imagePath);
                },
              ),
          ],
        ),
      ),
    );
  }
}
