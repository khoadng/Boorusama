// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

// Project imports:
import '../foundation/platform.dart';
import 'dummy_home_widget_manager.dart';
import 'home_widget_manager.dart';

final homeWidgetProvider = Provider<HomeWidgetManager>((ref) {
  // Only support Android for now
  return isAndroid() ? HomeWidgetManager() : DummyHomeWidgetManager();
});

final canPinWidgetProvider = FutureProvider<bool>((ref) async {
  if (!isAndroid()) return false;

  final res = await HomeWidget.isRequestPinWidgetSupported();

  return res ?? false;
});
