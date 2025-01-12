// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';
import 'package:home_widget/home_widget.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../configs/config.dart';
import '../settings/settings.dart';

class ConfigData {
  const ConfigData({
    required this.id,
    required this.name,
    required this.url,
    required this.shortName,
  });

  factory ConfigData.fromBooruConfig(BooruConfig config) {
    return ConfigData(
      id: config.id.toString(),
      name: config.name,
      url: config.url,
      shortName: config.auth.booruType.name,
    );
  }

  factory ConfigData.fromJson(Map<String, dynamic> json) {
    return ConfigData(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      shortName: json['shortName'] as String,
    );
  }

  final String id;
  final String name;
  final String url;
  final String shortName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'shortName': shortName,
      };
}

class HomeWidgetManager {
  static const _packageName = 'com.degenk.boorusama';
  static const _widgetKey = 'widgets_data';
  static const _receiverName = 'HomeWidgetReceiver';

  static const qualifiedAndroidName = '$_packageName.$_receiverName';

  Future<void> updateWidget(
    List<BooruConfig> configs,
    Settings settings,
  ) async {
    final orders = settings.booruConfigIdOrderList;

    final orderedConfigs = orders
        .map((id) => configs.firstWhereOrNull((e) => e.id == id))
        .toList(growable: false);

    final configData =
        orderedConfigs.nonNulls.map(ConfigData.fromBooruConfig).toList();
    final json = configData.map((e) => e.toJson()).toList();
    final jsonStr = jsonEncode(json);

    await HomeWidget.saveWidgetData(_widgetKey, jsonStr);
    await HomeWidget.updateWidget(
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }

  Future<void> pinToHomeScreen({
    required BooruConfig config,
  }) async {
    final supported = (await HomeWidget.isRequestPinWidgetSupported()) ?? false;

    if (supported) {
      await HomeWidget.requestPinWidget(
        qualifiedAndroidName: qualifiedAndroidName,
      );
    } else {
      showToast('This device does not support pinning widgets');
    }
  }

  Future<bool> hasInstalledWidgets() async {
    final data = await HomeWidget.getInstalledWidgets();

    return data.isNotEmpty;
  }
}
