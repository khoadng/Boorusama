// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shelf/shelf.dart';

// Project imports:
import '../data_converter2.dart';
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
  int get version; // data format version
  BackupSourceConfig get uiConfig;

  // Converter for version metadata handling
  DataBackupConverter2 get converter;

  Future<Response> serveData(Request request);
  Future<void> consumeData(String serverUrl);
  Future<void> exportToDirectory(String directoryPath);
  Future<void> exportToFile(String filePath);
  Future<void> importFromFile(String filePath);

  Future<void> exportToClipboard() => throw UnsupportedError(
    'Clipboard export not supported for this data type',
  );

  Future<void> importFromClipboard() => throw UnsupportedError(
    'Clipboard import not supported for this data type',
  );

  Future<ExportDataPayload> parseImportData(String data);
}
