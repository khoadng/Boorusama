// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/engine/engine.dart';
import '../../../../configs/config.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/widgets.dart';
import '../providers/details_layout_provider.dart';
import '../routes/route_utils.dart';
import '../types/custom_details.dart';
import '../types/details_part.dart';

class DetailsConfigPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final details =
        layout.details ?? convertDetailsParts(uiBuilder.full.keys.toList());
    final previewDetails =
        layout.previewDetails ??
        convertDetailsParts(uiBuilder.preview.keys.toList());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.t.booru.appearance.image_viewer_layout.widget_title,
        ),
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
                      title: context
                          .t
                          .booru
                          .appearance
                          .image_viewer_layout
                          .preview_widgets,
                      onPressed: () => goToDetailsLayoutManagerPage(
                        ref,
                        params: DetailsLayoutManagerParams(
                          details: previewDetails,
                          availableParts: uiBuilder.buildablePreviewParts
                              .toSet(),
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
                      title: context
                          .t
                          .booru
                          .appearance
                          .image_viewer_layout
                          .full_info_widgets,
                      onPressed: () => goToDetailsLayoutManagerPage(
                        ref,
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
              context.t.booru.appearance.image_viewer_layout.storage_tooltip,
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
              label: translateRawDetailsPartName(context, part.name),
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
          child: Text(context.t.settings.appearance.customize),
        ),
      ),
    );
  }
}
