// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

// Project imports:
import 'home_widget_manager.dart';

final homeWidgetProvider = Provider<HomeWidgetManager>((ref) {
  return HomeWidgetManager();
});

final canPinWidgetProvider = FutureProvider<bool>((ref) async {
  final res = await HomeWidget.isRequestPinWidgetSupported();

  return res ?? false;
});
