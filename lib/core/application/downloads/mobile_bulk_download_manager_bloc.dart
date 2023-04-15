// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/device_info_service.dart';
import 'package:boorusama/core/permission.dart';

class MobileBulkDownloadManagerBloc<T extends Post>
    extends BulkDownloadManagerBloc<T> {
  MobileBulkDownloadManagerBloc({
    required super.bulkPostDownloadBloc,
    required DeviceInfo deviceInfo,
  }) : super(
          permissionChecker: () => Permission.storage.status,
          permissionRequester: () => requestMediaPermissions(deviceInfo),
        );
}
