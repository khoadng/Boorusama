// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'export_data_page.dart';
import 'import_data_page.dart';

final serverPortProvider = StateProvider<int?>((ref) => null);

enum TransferMode {
  import,
  export,
}

class SyncDataPage extends ConsumerStatefulWidget {
  const SyncDataPage({
    super.key,
    required this.mode,
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
