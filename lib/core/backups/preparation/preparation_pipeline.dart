// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:version/version.dart';

// Project imports:
import '../../../foundation/version.dart';
import '../types/types.dart';
import 'backward_import_alert_dialog.dart';
import 'version_checking.dart';
import 'version_mismatch_alert_dialog.dart';

abstract class PreparationStep<T> {
  const PreparationStep();

  Future<PreparationContext<T>> execute(
    PreparationContext<T> context,
    BuildContext? uiContext,
  );
}

class PreparationContext<T> {
  const PreparationContext({
    required this.metadata,
    required this.parsedData,
    this.versionCheck,
  });

  final ExportDataPayload metadata;
  final T parsedData;
  final VersionCheckInfo? versionCheck;

  PreparationContext<T> copyWith({
    VersionCheckInfo? versionCheck,
  }) => PreparationContext(
    metadata: metadata,
    parsedData: parsedData,
    versionCheck: versionCheck ?? this.versionCheck,
  );
}

class ImportCancelledException implements Exception {
  const ImportCancelledException();
}

// Helper functions
Future<void> requireUIConfirmation(
  BuildContext? uiContext,
  Future<bool?> Function(BuildContext) showDialog,
) async {
  if (uiContext?.mounted != true) return;

  final confirmed = await showDialog(uiContext!);
  if (confirmed != true) throw const ImportCancelledException();
}

PreparationContext<T> setVersionCheck<T>(
  PreparationContext<T> context,
  VersionCheckInfo info,
) => context.copyWith(versionCheck: info);

class VersionCheckStep<T> extends PreparationStep<T> {
  const VersionCheckStep({
    required this.currentVersion,
    this.dataTypeName,
  });

  final Version? currentVersion;
  final String? dataTypeName;

  @override
  Future<PreparationContext<T>> execute(
    PreparationContext<T> context,
    BuildContext? uiContext,
  ) async {
    final versionCheck = _checkVersion(context.metadata);

    // Handle version confirmation if needed
    switch (versionCheck.result) {
      case VersionCheckResult.compatible:
        break;
      case VersionCheckResult.needsUserConfirmation:
        await _handleVersionConfirmation(versionCheck, uiContext);
      case VersionCheckResult.incompatible:
        throw Exception(
          versionCheck.message ?? 'Incompatible version detected',
        );
    }

    return setVersionCheck(context, versionCheck);
  }

  Future<void> _handleVersionConfirmation(
    VersionCheckInfo versionCheck,
    BuildContext? uiContext,
  ) async {
    final current = versionCheck.currentVersion;
    final import = versionCheck.importVersion;

    if (current == null || import == null) return;

    if (current.significantlyLowerThan(import)) {
      await requireUIConfirmation(
        uiContext,
        (context) => showBackwardImportAlertDialog(
          context: context,
          exportVersion: import,
        ),
      );
    } else {
      await requireUIConfirmation(
        uiContext,
        (context) => showVersionMismatchAlertDialog(
          context: context,
          importVersion: import,
          currentVersion: current,
          dataTypeName: dataTypeName,
        ),
      );
    }
  }

  VersionCheckInfo _checkVersion(ExportDataPayload data) {
    final current = currentVersion;
    final import = data.exportVersion;

    if (current == null || import == null) {
      return VersionCheckInfo(
        result: VersionCheckResult.compatible,
        currentVersion: current,
        importVersion: import,
      );
    }

    if (current.significantlyLowerThan(import)) {
      return VersionCheckInfo(
        result: VersionCheckResult.needsUserConfirmation,
        currentVersion: current,
        importVersion: import,
        message: 'Importing from newer version may cause issues',
      );
    }

    if (current.significantlyHigherThan(import)) {
      return VersionCheckInfo(
        result: VersionCheckResult.needsUserConfirmation,
        currentVersion: current,
        importVersion: import,
        message: 'Importing from older version may lose data',
      );
    }

    return VersionCheckInfo(
      result: VersionCheckResult.compatible,
      currentVersion: current,
      importVersion: import,
    );
  }
}

// Validation step for data integrity
class ValidationStep<T> extends PreparationStep<T> {
  const ValidationStep({
    this.validator,
  });

  final bool Function(T data)? validator;

  @override
  Future<PreparationContext<T>> execute(
    PreparationContext<T> context,
    BuildContext? uiContext,
  ) async {
    if (validator != null && !validator!(context.parsedData)) {
      throw Exception('Data validation failed');
    }
    return context;
  }
}

// Main preparation pipeline
class PreparationPipeline<T> {
  const PreparationPipeline({
    required this.steps,
  });

  final List<PreparationStep<T>> steps;

  Future<PreparationContext<T>> execute(
    PreparationContext<T> initialContext,
    BuildContext? uiContext,
  ) async {
    var context = initialContext;

    for (final step in steps) {
      context = await step.execute(context, uiContext);
    }

    return context;
  }
}
