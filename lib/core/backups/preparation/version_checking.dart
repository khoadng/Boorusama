// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:version/version.dart';

// Project imports:
import '../types/types.dart';
import '../utils/data_converter.dart';
import 'preparation_pipeline.dart';

enum VersionCheckResult {
  compatible,
  needsUserConfirmation,
  incompatible,
}

class VersionCheckInfo {
  const VersionCheckInfo({
    required this.result,
    required this.currentVersion,
    required this.importVersion,
    this.message,
  });

  final VersionCheckResult result;
  final Version? currentVersion;
  final Version? importVersion;
  final String? message;
}

class ImportPreparation {
  const ImportPreparation({
    required this.versionCheck,
    required this.executeImport,
  });

  final VersionCheckInfo versionCheck;
  final Future<void> Function() executeImport;
}

class ImportPreparationBuilder<T> {
  const ImportPreparationBuilder({
    required this.converter,
    required this.currentVersion,
    this.extraSteps = const [],
    this.validator,
    this.dataTypeName,
  });

  final DataBackupConverter converter;
  final Version? currentVersion;
  final List<PreparationStep<T>> extraSteps;
  final bool Function(T data)? validator;
  final String? dataTypeName;

  Future<ImportPreparation> prepare(
    String data,
    T Function(ExportDataPayload payload) parser,
    Future<void> Function(T data, BuildContext? uiContext) executor,
    BuildContext? uiContext,
  ) async {
    final metadata = converter.decode(data: data);
    final parsed = parser(metadata);

    final initialContext = PreparationContext<T>(
      metadata: metadata,
      parsedData: parsed,
    );

    final pipeline = PreparationPipeline<T>(
      steps: [
        VersionCheckStep<T>(
          currentVersion: currentVersion,
          dataTypeName: dataTypeName,
        ),
        ValidationStep<T>(validator: validator),
        ...extraSteps,
      ],
    );

    final finalContext = await pipeline.execute(initialContext, uiContext);

    return ImportPreparation(
      versionCheck:
          finalContext.versionCheck ??
          const VersionCheckInfo(
            result: VersionCheckResult.compatible,
            currentVersion: null,
            importVersion: null,
          ),
      executeImport: () => executor(finalContext.parsedData, uiContext),
    );
  }
}
