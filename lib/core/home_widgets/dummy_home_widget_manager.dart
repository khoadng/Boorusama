// Project imports:
import '../configs/src/booru_config.dart';
import '../settings/src/types/settings.dart';
import 'home_widget_manager.dart';

class DummyHomeWidgetManager implements HomeWidgetManager {
  @override
  Future<bool> hasInstalledWidgets() async {
    return false;
  }

  @override
  Future<void> pinToHomeScreen({required BooruConfig config}) async {}

  @override
  Future<void> updateWidget(
      List<BooruConfig> configs, Settings settings) async {}
}
