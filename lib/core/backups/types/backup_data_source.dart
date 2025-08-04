// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../preparation/version_checking.dart';

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
  });

  final ServerCapability server; // Required for transfer system
  final FileCapability? file;
  final ClipboardCapability? clipboard;
}

abstract class BackupDataSource {
  String get id;
  int get priority;
  String get displayName;
  BackupCapabilities get capabilities;
  Widget buildTile(BuildContext context);
}
