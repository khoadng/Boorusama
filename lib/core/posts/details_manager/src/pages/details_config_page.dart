// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../boorus/engine/engine.dart';
import '../../../../configs/config.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/widgets.dart';
import '../providers/details_layout_provider.dart';
import '../routes/route_utils.dart';
import '../types/custom_details.dart';

class DetailsConfigPage extends StatelessWidget {
  const DetailsConfigPage({
    required this.uiBuilder,
    required this.layout,
    required this.onLayoutUpdated,
    super.key,
  });

  final LayoutConfigs layout;
  final PostDetailsUIBuilder uiBuilder;
  final void Function(LayoutConfigs layout) onLayoutUpdated;

  @override
  Widget build(BuildContext context) {
    final details =
        layout.details ?? convertDetailsParts(uiBuilder.full.keys.toList());
    final previewDetails = layout.previewDetails ??
        convertDetailsParts(uiBuilder.preview.keys.toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widgets'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Title(
                      title: 'Preview widgets',
                      onPressed: () => goToDetailsLayoutManagerPage(
                        context,
                        params: DetailsLayoutManagerParams(
                          details: previewDetails,
                          availableParts:
                              uiBuilder.buildablePreviewParts.toSet(),
                          defaultParts: uiBuilder.preview.keys.toSet(),
                          onUpdate: (parts) {
                            onLayoutUpdated(
                              layout.copyWith(
                                previewDetails: () => parts,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    _WidgetList(parts: previewDetails),
                    const SizedBox(height: 24),
                    _Title(
                      title: 'Full informaton widgets',
                      onPressed: () => goToDetailsLayoutManagerPage(
                        context,
                        params: DetailsLayoutManagerParams(
                          details: details,
                          availableParts: uiBuilder.full.keys.toSet(),
                          defaultParts: uiBuilder.full.keys.toSet(),
                          onUpdate: (parts) {
                            onLayoutUpdated(
                              layout.copyWith(
                                details: () => parts,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    _WidgetList(parts: details),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Text(
              'All changes are saved to your current profile.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.hintColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetList extends StatelessWidget {
  const _WidgetList({
    required this.parts,
  });

  final List<CustomDetailsPartKey> parts;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: parts
          .map(
            (part) => CompactChip(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              borderRadius: BorderRadius.circular(12),
              label: part.name,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            ),
          )
          .toList(),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
    required this.onPressed,
  });

  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: TextButton(
          onPressed: onPressed,
          child: const Text('Customize'),
        ),
      ),
    );
  }
}
