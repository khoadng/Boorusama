// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../preparation/version_checking.dart';

class SyncCapability {
  const SyncCapability({
    required this.getUniqueIdFromJson,
    required this.importResolved,
    this.getTimestampFromJson,
  });

  final Object Function(Map<String, dynamic> json) getUniqueIdFromJson;
  final Future<void> Function(List<Map<String, dynamic>> data) importResolved;

  /// Optional timestamp extractor for auto-resolving conflicts.
  /// If provided and both items have timestamps, the newer one wins automatically.
  final DateTime? Function(Map<String, dynamic> json)? getTimestampFromJson;
}

class ServerCapability {
  const ServerCapability({
    required this.export,
    required this.prepareImport,
  });

  final Future<shelf.Response> Function(shelf.Request request) export;
  final Future<ImportPreparation> Function(
    String serverUrl,
    BuildContext? uiContext,
  )
  prepareImport;
}

class FileCapability {
  const FileCapability({
    required this.export,
    required this.prepareImport,
  });

  final Future<void> Function(String path) export;
  final Future<ImportPreparation> Function(String path, BuildContext? uiContext)
  prepareImport;
}

class ClipboardCapability {
  const ClipboardCapability({
    required this.export,
    required this.prepareImport,
  });

  final Future<void> Function() export;
  final Future<ImportPreparation> Function(BuildContext? uiContext)
  prepareImport;
}

class BackupCapabilities {
  const BackupCapabilities({
    required this.server,
    this.file,
    this.clipboard,
    this.sync,
  });

  final ServerCapability server; // Required for transfer system
  final FileCapability? file;
  final ClipboardCapability? clipboard;
  final SyncCapability? sync;
}

abstract class BackupDataSource {
  String get id;
  int get priority;
  String get displayName;
  BackupCapabilities get capabilities;
  Widget buildTile(BuildContext context);
}
