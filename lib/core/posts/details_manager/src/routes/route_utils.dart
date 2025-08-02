// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/data.dart';
import '../../../../configs/config/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../configs/manage/providers.dart';
import '../../../../router.dart';
import '../providers/details_layout_provider.dart';
import '../types/custom_details.dart';

void goToDetailsLayoutManagerPage(
  WidgetRef ref, {
  required DetailsLayoutManagerParams params,
}) {
  ref.router.push(
    '/details_manager',
    extra: params,
  );
}

void goToDetailsLayoutManagerForPreviewWidgets(WidgetRef ref) {
  final layout = ref.watchLayoutConfigs ?? const LayoutConfigs.undefined();
  final uiBuilder = ref
      .watch(booruBuilderProvider(ref.watchConfigAuth))
      ?.postDetailsUIBuilder;

  if (uiBuilder == null) return;

  final previewDetails =
      layout.previewDetails ??
      convertDetailsParts(uiBuilder.preview.keys.toList());

  final notifier = ref.watch(booruConfigProvider.notifier);
  final currentConfigNotifier = ref.watch(
    currentBooruConfigProvider.notifier,
  );
  final config = ref.watchConfig;

  goToDetailsLayoutManagerPage(
    ref,
    params: DetailsLayoutManagerParams(
      details: previewDetails,
      availableParts: uiBuilder.buildablePreviewParts.toSet(),
      defaultParts: uiBuilder.preview.keys.toSet(),
      onUpdate: (parts) {
        notifier.update(
          booruConfigData: config
              .copyWith(
                layout: () => layout.copyWith(
                  previewDetails: () => parts,
                ),
              )
              .toBooruConfigData(),
          oldConfigId: config.id,
          onSuccess: (booruConfig) {
            currentConfigNotifier.update(booruConfig);
          },
        );
      },
    ),
  );
}

void goToDetailsLayoutManagerForFullWidgets(WidgetRef ref) {
  final layout = ref.watchLayoutConfigs ?? const LayoutConfigs.undefined();
  final uiBuilder = ref
      .watch(booruBuilderProvider(ref.watchConfigAuth))
      ?.postDetailsUIBuilder;

  if (uiBuilder == null) return;

  final details =
      layout.details ?? convertDetailsParts(uiBuilder.full.keys.toList());

  final notifier = ref.watch(booruConfigProvider.notifier);
  final currentConfigNotifier = ref.watch(
    currentBooruConfigProvider.notifier,
  );
  final config = ref.watchConfig;

  goToDetailsLayoutManagerPage(
    ref,
    params: DetailsLayoutManagerParams(
      details: details,
      availableParts: uiBuilder.full.keys.toSet(),
      defaultParts: uiBuilder.full.keys.toSet(),
      onUpdate: (parts) {
        notifier.update(
          booruConfigData: config
              .copyWith(
                layout: () => layout.copyWith(
                  details: () => parts,
                ),
              )
              .toBooruConfigData(),
          oldConfigId: config.id,
          onSuccess: (booruConfig) {
            currentConfigNotifier.update(booruConfig);
          },
        );
      },
    ),
  );
}
