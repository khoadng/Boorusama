// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'sync_data_page.dart';

void goToSyncDataPage(
  BuildContext context, {
  required TransferMode mode,
}) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => SyncDataPage(
        mode: mode,
      ),
    ),
  );
}
