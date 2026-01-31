// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../preparation/version_checking.dart';
import '../sync/merge_strategy.dart';
import '../sync/types.dart';

class SyncCapability<T> {
  const SyncCapability({
    required this.mergeStrategy,
    required this.handlePush,
    required this.getUniqueIdFromJson,
    required this.importResolved,
  });

  final MergeStrategy<T> mergeStrategy;
  final Future<SyncStats> Function(shelf.Request request) handlePush;
  final Object Function(Map<String, dynamic> json) getUniqueIdFromJson;

  /// Import resolved data directly, replacing existing items and adding new ones.
  /// Used by the hub to apply resolved sync data to its own storage.
  final Future<void> Function(List<Map<String, dynamic>> data) importResolved;
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
