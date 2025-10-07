import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

/// A quick fix that converts relative imports referencing "/src/" directories
/// to use barrel file imports instead.
/// Example: '../../post/src/routes/route_utils.dart' -> '../../post/routes.dart'
class FixRelativeSrcImports extends ResolvedCorrectionProducer {
  FixRelativeSrcImports({required super.context});

  static const _fixKind = FixKind(
    'dart.fix.fixRelativeSrcImports',
    DartFixKindPriority.standard,
    'Use barrel file import',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is StringLiteral) {
      final parent = targetNode.parent;
      if (parent is ImportDirective) {
        await _processImportDirective(builder, parent);
      }
    } else if (targetNode is ImportDirective) {
      await _processImportDirective(builder, targetNode);
    }
  }

  Future<void> _processImportDirective(
    ChangeBuilder builder,
    ImportDirective importDirective,
  ) async {
    final uri = importDirective.uri.stringValue;

    if (uri == null) {
      return;
    }

    // Only handle relative imports containing /src/
    if (!_isRelativeImport(uri) || !uri.contains('/src/')) {
      return;
    }

    // TODO: Remove this check in the future to handle all /src/ imports
    // For now, only handle routes imports
    if (!uri.contains('/src/routes/')) {
      return;
    }

    // Convert to barrel import by removing /src/ part
    final newUri = _convertToBarrelImport(uri);

    if (newUri == uri) {
      // No change needed
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        range.node(importDirective.uri),
        "'$newUri'",
      );
    });
  }

  bool _isRelativeImport(String uri) {
    return uri.startsWith('./') || uri.startsWith('../');
  }

  String _convertToBarrelImport(String uri) {
    // Convert: ../../post/src/routes/route_utils.dart
    // To:      ../../post/routes.dart
    //
    // Convert: ../../post/src/widgets/button.dart
    // To:      ../../post/widgets.dart

    // Find the /src/ part and extract the directory after it
    final srcIndex = uri.indexOf('/src/');
    if (srcIndex == -1) {
      return uri;
    }

    // Get the part before /src/
    final beforeSrc = uri.substring(0, srcIndex);

    // Get the part after /src/
    final afterSrc = uri.substring(srcIndex + 5); // 5 = length of '/src/'

    // Find the first directory after /src/
    final nextSlashIndex = afterSrc.indexOf('/');
    if (nextSlashIndex == -1) {
      // No subdirectory, just use the name as is
      // e.g., /src/routes -> /routes.dart
      return '$beforeSrc/$afterSrc.dart';
    }

    // Extract the directory name (e.g., 'routes' from 'routes/route_utils.dart')
    final directoryName = afterSrc.substring(0, nextSlashIndex);

    // Return the barrel import
    return '$beforeSrc/$directoryName.dart';
  }
}
