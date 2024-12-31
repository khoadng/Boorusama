// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'export/export_data_page.dart';
import 'import/import_data_page.dart';

enum TransferMode {
  import,
  export,
}

class SyncDataPage extends ConsumerStatefulWidget {
  const SyncDataPage({
    required this.mode,
    super.key,
  });

  final TransferMode mode;

  @override
  ConsumerState<SyncDataPage> createState() => _SyncDataPageState();
}

class _SyncDataPageState extends ConsumerState<SyncDataPage> {
  @override
  Widget build(BuildContext context) {
    return widget.mode == TransferMode.export
        ? const ExportDataPage()
        : const ImportDataPage();
  }
}
