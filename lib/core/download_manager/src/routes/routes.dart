// Project imports:
import '../../../router.dart';
import '../pages/download_manager_page.dart';

final downloadManagerRoutes = GoRoute(
  path: 'download_manager',
  name: '/download_manager',
  pageBuilder: genericMobilePageBuilder(
    builder: (context, state) => DownloadManagerGatewayPage(
      filter: state.uri.queryParameters['filter'],
      group: state.uri.queryParameters['group'],
    ),
  ),
);
