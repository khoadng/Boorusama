// Project imports:
import 'app_info.dart';

class AppInfoProvider {
  AppInfoProvider(this.appInfo);

  final AppInfo appInfo;

  AppInfo getAppInfo() => appInfo;
}
