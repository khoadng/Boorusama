// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../boorus/engine/engine.dart';
import '../../../../configs/config.dart';
import '../../../../widgets/widgets.dart';
import '../routes/route_utils.dart';
import '../types/custom_details.dart';

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
        title: const Text('Widgets'),
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
                    defaultParts: uiBuilder.preview.keys.toSet(),
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
                    defaultParts: uiBuilder.full.keys.toSet(),
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
