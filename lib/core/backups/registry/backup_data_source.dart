// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:shelf/shelf.dart';

// Project imports:
import '../types.dart';

enum BackupActionType { export, import, exportClipboard, importClipboard }

class BackupAction {
  const BackupAction({
    required this.type,
    required this.label,
    this.enabled = true,
  });

  final BackupActionType type;
  final String label;
  final bool enabled;
}

class BackupSourceConfig {
  const BackupSourceConfig({
    required this.icon,
    required this.actions,
    this.subtitle,
    this.extraWidget,
  });

  final IconData icon;
  final List<BackupAction> actions;
  final String? subtitle;
  final Widget? extraWidget;
}

abstract class BackupDataSource {
  String get id; // unique identifier (e.g., 'settings')
  String get displayName; // UI label (e.g., 'Settings')
  int get priority; // export/import order (0 = highest)
  BackupSourceConfig get uiConfig;

  Future<Either<ExportError, Response>> serveData(Request request);
  Future<Either<ImportError, Unit>> consumeData(String serverUrl);
  Future<Either<ExportError, Unit>> exportToDirectory(String directoryPath);
  Future<Either<ExportError, Unit>> exportToFile(String filePath);
  Future<Either<ImportError, Unit>> importFromFile(String filePath);

  Future<Either<ExportError, Unit>> exportToClipboard() => Future.value(
    left(
      const DataExportError(
        error: 'Clipboard export not supported for this data type',
        stackTrace: StackTrace.empty,
      ),
    ),
  );

  Future<Either<ImportError, Unit>> importFromClipboard() =>
      Future.value(left(const ImportInvalidJson()));
}
