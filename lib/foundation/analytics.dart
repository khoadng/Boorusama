// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/settings/settings.dart';

final analyticsProvider = Provider<AnalyticsInterface>(
  (ref) => NoAnalyticsInterface(),
);

bool defaultBooruRouteFilter(Route<dynamic>? route) =>
    route is PageRoute ||
    route is ModalBottomSheetRoute ||
    route is DialogRoute;

class AnalyticsNetworkInfo extends Equatable {
  const AnalyticsNetworkInfo({
    required this.types,
    required this.state,
  });

  const AnalyticsNetworkInfo.error(String message)
      : types = 'none',
        state = 'error: $message';

  const AnalyticsNetworkInfo.connected(this.types) : state = 'connected';

  const AnalyticsNetworkInfo.disconnected()
      : types = 'none',
        state = 'disconnected';

  final String types;
  final String state;

  @override
  List<Object> get props => [types, state];
}

class AnalyticsViewInfo extends Equatable {
  const AnalyticsViewInfo({
    required this.aspectRatio,
  });

  AnalyticsViewInfo copyWith({
    double? aspectRatio,
  }) {
    return AnalyticsViewInfo(
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  final double aspectRatio;

  @override
  List<Object> get props => [aspectRatio];
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

class NoAnalyticsInterface implements AnalyticsInterface {
  @override
  bool get enabled => false;

  @override
  bool isPlatformSupported() => false;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> changeCurrentAnalyticConfig(BooruConfig config) async {}

  @override
  Future<void> updateNetworkInfo(AnalyticsNetworkInfo info) async {}

  @override
  Future<void> updateViewInfo(AnalyticsViewInfo info) async {}

  @override
  NavigatorObserver getAnalyticsObserver() => NavigatorObserver();

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {}

  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {}
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

    _logChangedEvent(
      oldValue: oldValue.defaultPreviewImageButtonAction ?? '<none>',
      newValue: newValue.defaultPreviewImageButtonAction ?? '<none>',
      eventName: 'preview_img_btn_changed',
      source: SettingsChangedSource.configs,
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

    _logChangedEvent(
      oldValue: oldValue.themeMode.name,
      newValue: newValue.themeMode.name,
      eventName: 'theme_changed',
      source: SettingsChangedSource.settings,
    );

    _logChangedEvent(
      oldValue: oldValue.enableDynamicColoring.toString(),
      newValue: newValue.enableDynamicColoring.toString(),
      eventName: 'dynamic_color_changed',
      source: SettingsChangedSource.settings,
    );

    _logChangedEvent(
      oldValue: oldValue.videoPlayerEngine.name,
      newValue: newValue.videoPlayerEngine.name,
      eventName: 'video_player_engine_changed',
      source: SettingsChangedSource.settings,
    );

    _logChangedEvent(
      oldValue: oldValue.booruConfigSelectorPosition.name,
      newValue: newValue.booruConfigSelectorPosition.name,
      eventName: 'configs_pos_changed',
      source: SettingsChangedSource.settings,
    );

    _logChangedEvent(
      oldValue: oldValue.booruConfigLabelVisibility.name,
      newValue: newValue.booruConfigLabelVisibility.name,
      eventName: 'config_label_vis_changed',
      source: SettingsChangedSource.settings,
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

class DebugPrintAnalyticsImpl implements AnalyticsInterface {
  DebugPrintAnalyticsImpl({
    this.enabled = false,
  });

  BooruConfig? _currentConfig;
  AnalyticsViewInfo? _deviceInfo;

  @override
  final bool enabled;

  @override
  bool isPlatformSupported() => enabled;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> changeCurrentAnalyticConfig(BooruConfig config) async {
    if (!enabled) return;
    _currentConfig = config;
  }

  @override
  Future<void> updateNetworkInfo(AnalyticsNetworkInfo info) async {}

  @override
  Future<void> updateViewInfo(AnalyticsViewInfo info) async {
    if (!enabled) return;
    _deviceInfo = info;
    debugPrint('Device aspect ratio: ${info.aspectRatio}');
  }

  @override
  NavigatorObserver getAnalyticsObserver() => enabled
      ? DebugPrintAnalyticsObserver(
          paramsExtractor: (settings) => defaultParamsExtractor(
            _currentConfig,
            _deviceInfo,
          ),
        )
      : NavigatorObserver();

  @override
  Future<void> logScreenView(String screenName) async {
    if (!enabled) return;
    final params = defaultParamsExtractor(
      _currentConfig,
      _deviceInfo,
    );

    _printDebugScreenView(
      screenName,
      parameters: params,
    );
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!enabled) return;
    debugPrint('Event: $name with parameters: $parameters');
  }
}

Map<String, dynamic> defaultParamsExtractor(
  BooruConfig? config,
  AnalyticsViewInfo? deviceInfo,
) {
  // only need last two digits of the aspect ratio
  final aspectRatioString = deviceInfo?.aspectRatio.toStringAsFixed(2);
  final aspectRatioNum =
      aspectRatioString != null ? double.tryParse(aspectRatioString) : null;

  return config != null
      ? {
          'hint_site': config.booruType.name,
          'url': Uri.tryParse(config.url)?.host,
          'has_login': config.apiKey != null && config.apiKey!.isNotEmpty,
          'rating': config.ratingVerdict,
          'viewport_aspect_ratio': aspectRatioNum,
        }
      : <String, dynamic>{};
}

class AnalyticsScope extends ConsumerStatefulWidget {
  const AnalyticsScope({
    super.key,
    required this.builder,
  });

  final Widget Function(bool analyticsEnabled) builder;

  @override
  ConsumerState<AnalyticsScope> createState() => _AnalyticsScopeState();
}

class _AnalyticsScopeState extends ConsumerState<AnalyticsScope>
    with WidgetsBindingObserver {
  double? _lastAspectRatio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateViewInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateViewInfo();
  }

  void _updateViewInfo() {
    final aspectRatio = View.of(context).physicalSize.aspectRatio;

    if (_lastAspectRatio == aspectRatio) return;

    ref.read(analyticsProvider).updateViewInfo(
          AnalyticsViewInfo(aspectRatio: aspectRatio),
        );

    _lastAspectRatio = aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);
    final enabled = analytics.enabled;

    ref.listen(
      currentBooruConfigProvider,
      (p, c) {
        if (p != c) {
          if (enabled) {
            analytics.changeCurrentAnalyticConfig(c);
          }
        }
      },
    );

    return widget.builder(enabled);
  }
}

void _printDebugScreenView(
  String screenName, {
  Map<String, dynamic>? parameters,
}) {
  debugPrint('ScreenView: [$screenName] with parameters: $parameters');
}

typedef ScreenNameExtractor = String? Function(RouteSettings settings);

String? defaultNameExtractor(RouteSettings settings) => settings.name;

typedef RouteFilter = bool Function(Route<dynamic>? route);

class DebugPrintAnalyticsObserver extends RouteObserver<ModalRoute<dynamic>> {
  DebugPrintAnalyticsObserver({
    required this.paramsExtractor,
    this.nameExtractor = defaultNameExtractor,
    this.routeFilter = defaultBooruRouteFilter,
  });

  final ScreenNameExtractor nameExtractor;
  final RouteFilter routeFilter;
  final Map<String, dynamic> Function(RouteSettings settings) paramsExtractor;

  void _sendScreenView(Route<dynamic> route) {
    final screenName = nameExtractor(route.settings);
    if (screenName != null) {
      final params = paramsExtractor(route.settings);
      _printDebugScreenView(screenName, parameters: params);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (routeFilter(route)) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && routeFilter(newRoute)) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null &&
        routeFilter(previousRoute) &&
        routeFilter(route)) {
      _sendScreenView(previousRoute);
    }
  }
}
