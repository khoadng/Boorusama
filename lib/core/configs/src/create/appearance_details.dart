// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import '../../../boorus/engine/providers.dart';
import '../../../posts/details/custom_details.dart';
import '../../../widgets/widgets.dart';
import '../../current.dart';
import '../../manage.dart';
import '../../ref.dart';
import '../booru_config.dart';
import '../booru_config_converter.dart';
import 'details_layout_manager_page.dart';

void goToQuickEditPostDetailsLayoutPage(
  BuildContext context,
) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const QuickEditDetailsConfigPage(),
    ),
  );
}

class QuickEditDetailsConfigPage extends ConsumerWidget {
  const QuickEditDetailsConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watchLayoutConfigs ?? const LayoutConfigs.undefined();

    final uiBuilder =
        ref.watchBooruBuilder(ref.watchConfigAuth)?.postDetailsUIBuilder;
    final details = layout.details ??
        convertDetailsParts(uiBuilder?.full.keys.toList() ?? []);
    final previewDetails = layout.previewDetails ??
        convertDetailsParts(uiBuilder?.preview.keys.toList() ?? []);

    if (uiBuilder == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
        ),
        body: const Center(
          child: Text('No builder found'),
        ),
      );
    }

    final notifier = ref.watch(booruConfigProvider.notifier);
    final currentConfigNotifier =
        ref.watch(currentBooruConfigProvider.notifier);
    final config = ref.watchConfig;

    return DetailsConfigPage(
      layout: layout,
      details: details,
      previewDetails: previewDetails,
      uiBuilder: uiBuilder,
      onLayoutUpdated: (layout) {
        notifier.update(
          booruConfigData: config
              .copyWith(
                layout: () => layout,
              )
              .toBooruConfigData(),
          oldConfigId: config.id,
          onSuccess: (booruConfig) {
            currentConfigNotifier.update(booruConfig);
          },
        );
      },
    );
  }
}

class DetailsConfigPage extends StatelessWidget {
  const DetailsConfigPage({
    required this.uiBuilder,
    required this.layout,
    required this.details,
    required this.previewDetails,
    required this.onLayoutUpdated,
    super.key,
  });

  final LayoutConfigs layout;
  final List<CustomDetailsPartKey> details;
  final List<CustomDetailsPartKey> previewDetails;
  final PostDetailsUIBuilder uiBuilder;
  final void Function(LayoutConfigs layout) onLayoutUpdated;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                title: const Text(
                  'Preview widgets',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: TextButton(
                  child: const Text('Customize'),
                  onPressed: () => goToDetailsLayoutManagerPage(
                    context,
                    details: previewDetails,
                    availableParts: uiBuilder.buildablePreviewParts.toSet(),
                    onDone: (parts) {
                      onLayoutUpdated(
                        layout.copyWith(
                          previewDetails: () => parts,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: previewDetails
                  .map(
                    (part) => CompactChip(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      label: part.name,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                title: const Text(
                  'Full informaton widgets',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: TextButton(
                  child: const Text('Customize'),
                  onPressed: () => goToDetailsLayoutManagerPage(
                    context,
                    details: details,
                    availableParts: uiBuilder.full.keys.toSet(),
                    onDone: (parts) {
                      onLayoutUpdated(
                        layout.copyWith(
                          details: () => parts,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: details
                  .map(
                    (part) => CompactChip(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      label: part.name,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
