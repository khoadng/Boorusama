// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../configs/config.dart';
import '../settings/settings.dart';
import 'analytics_network_info.dart';
import 'analytics_view_info.dart';

bool defaultBooruRouteFilter(Route<dynamic>? route) =>
    route is PageRoute ||
    route is ModalBottomSheetRoute ||
    route is DialogRoute;

Map<String, dynamic> defaultParamsExtractor(
  BooruConfig? config,
  AnalyticsViewInfo? deviceInfo,
) {
  // only need last two digits of the aspect ratio
  final aspectRatioString = deviceInfo?.aspectRatio.toStringAsFixed(2);
  final aspectRatioNum = aspectRatioString != null
      ? double.tryParse(aspectRatioString)
      : null;

  return {
    if (config != null) ...{
      'hint_site': config.auth.booruType.name,
      'url': Uri.tryParse(config.url)?.host,
      'has_login': config.apiKey != null && config.apiKey!.isNotEmpty,
      'rating': config.search.filter.ratingVerdict,
    },
    'viewport_aspect_ratio': aspectRatioNum,
  };
}

abstract interface class AnalyticsInterface {
  bool get enabled;
  bool isPlatformSupported();
  Future<void> ensureInitialized();
  Future<void> changeCurrentAnalyticConfig(BooruConfig config);
  Future<void> updateNetworkInfo(AnalyticsNetworkInfo info);
  Future<void> updateViewInfo(AnalyticsViewInfo info);
  NavigatorObserver getAnalyticsObserver();

  Future<void> logScreenView(String screenName);

  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  });
}

extension AnalyticsInterfaceX on AnalyticsInterface {
  Future<void> _logChangedEvent({
    required String oldValue,
    required String newValue,
    required String eventName,
    required SettingsChangedSource source,
  }) async {
    if (!enabled) return;

    if (oldValue != newValue) {
      await logEvent(
        eventName,
        parameters: {
          'source': source.name,
          'old_value': oldValue,
          'new_value': newValue,
        },
      );
    }
  }

  Future<void> logConfigChangedEvent({
    required BooruConfig oldValue,
    required BooruConfig newValue,
  }) async {
    if (!enabled) return;

    unawaited(
      _logChangedEvent(
        oldValue: oldValue.defaultPreviewImageButtonAction ?? '<none>',
        newValue: newValue.defaultPreviewImageButtonAction ?? '<none>',
        eventName: 'preview_img_btn_changed',
        source: SettingsChangedSource.configs,
      ),
    );

    _logListingChangedEvent(
      oldValue: oldValue.listing?.settings,
      newValue: newValue.listing?.settings,
      source: SettingsChangedSource.configs,
    );
  }

  Future<void> logSettingsChangedEvent({
    required Settings oldValue,
    required Settings newValue,
  }) async {
    if (!enabled) return;

    unawaited(
      _logChangedEvent(
        oldValue: oldValue.themeMode.name,
        newValue: newValue.themeMode.name,
        eventName: 'theme_changed',
        source: SettingsChangedSource.settings,
      ),
    );

    unawaited(
      _logChangedEvent(
        oldValue: oldValue.enableDynamicColoring.toString(),
        newValue: newValue.enableDynamicColoring.toString(),
        eventName: 'dynamic_color_changed',
        source: SettingsChangedSource.settings,
      ),
    );

    unawaited(
      _logChangedEvent(
        oldValue: oldValue.mediaKitHardwareDecoding.toString(),
        newValue: newValue.mediaKitHardwareDecoding.toString(),
        eventName: 'media_kit_hardware_decoding_changed',
        source: SettingsChangedSource.settings,
      ),
    );

    unawaited(
      _logChangedEvent(
        oldValue: oldValue.booruConfigSelectorPosition.name,
        newValue: newValue.booruConfigSelectorPosition.name,
        eventName: 'configs_pos_changed',
        source: SettingsChangedSource.settings,
      ),
    );

    unawaited(
      _logChangedEvent(
        oldValue: oldValue.booruConfigLabelVisibility.name,
        newValue: newValue.booruConfigLabelVisibility.name,
        eventName: 'config_label_vis_changed',
        source: SettingsChangedSource.settings,
      ),
    );

    _logListingChangedEvent(
      oldValue: oldValue.listing,
      newValue: newValue.listing,
      source: SettingsChangedSource.settings,
    );
  }

  void _logListingChangedEvent({
    required ImageListingSettings? oldValue,
    required ImageListingSettings? newValue,
    required SettingsChangedSource source,
  }) {
    if (!enabled) return;

    _logChangedEvent(
      oldValue: oldValue?.imageListType.name ?? '<none>',
      newValue: newValue?.imageListType.name ?? '<none>',
      eventName: 'image_list_type_changed',
      source: source,
    );

    _logChangedEvent(
      oldValue: oldValue?.gridSize.name ?? '<none>',
      newValue: newValue?.gridSize.name ?? '<none>',
      eventName: 'grid_size_changed',
      source: source,
    );

    _logChangedEvent(
      oldValue: oldValue?.pageMode.name ?? '<none>',
      newValue: newValue?.pageMode.name ?? '<none>',
      eventName: 'page_mode_changed',
      source: source,
    );

    _logChangedEvent(
      oldValue: oldValue?.imageQuality.name ?? '<none>',
      newValue: newValue?.imageQuality.name ?? '<none>',
      eventName: 'image_quality_changed',
      source: source,
    );
  }
}

enum SettingsChangedSource {
  settings,
  configs,
}
