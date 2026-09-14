// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../filesystem.dart';
import '../picker.dart';
import 'crash_report_writer.dart';

final class FileSystemCrashReportWriter implements CrashReportWriter {
  const FileSystemCrashReportWriter();

  @override
  Future<void> save(BuildContext context, String data) =>
      pickDirectoryPathToastOnError(
        context: context,
        picker: ProviderScope.containerOf(context).read(appFilePickerProvider),
        onPick: (path) async {
          const fs = IoFileSystem();
          await fs.writeString('$path/boorusama_crash.txt', data);
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Copied'),
              duration: KurumiDurations.shortToast,
            ),
          );
        },
      );
}
