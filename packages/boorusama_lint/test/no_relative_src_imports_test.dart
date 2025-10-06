// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:boorusama_lint/src/rules/no_relative_src_imports.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRelativeSrcImportsTest);
  });
}

@reflectiveTest
class NoRelativeSrcImportsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(NoRelativeSrcImports());
    super.setUp();
  }

  @override
  String get analysisRule => 'no_relative_src_imports';

  Future<void> test_relativeImportWithSrc_detected() async {
    // The rule should detect relative imports that contain '/src/'
    await assertDiagnostics(
      '''
import './src/models/user.dart';
''',
      [lint(0, 32)],
    );
  }

  Future<void> test_relativeImportParentWithSrc_detected() async {
    await assertDiagnostics(
      '''
import '../src/utils/helper.dart';
''',
      [lint(0, 34)],
    );
  }

  Future<void> test_relativeImportWithoutSrc_noLint() async {
    await assertNoDiagnostics(
      '''
import './models/user.dart';
''',
    );
  }

  Future<void> test_packageImportWithSrc_noLint() async {
    // Package imports are allowed, even to src directories
    await assertNoDiagnostics(
      '''
import 'package:test/src/internal.dart';
''',
    );
  }

  Future<void> test_dartImport_noLint() async {
    await assertNoDiagnostics(
      '''
import 'dart:core';
''',
    );
  }

  Future<void> test_multipleRelativeSrcImports_detected() async {
    await assertDiagnostics(
      '''
import './src/models/user.dart';
import '../src/utils/helper.dart';
''',
      [
        lint(0, 32),
        lint(33, 34),
      ],
    );
  }

  Future<void> test_mixedImports_onlyRelativeSrcDetected() async {
    await assertDiagnostics(
      '''
import 'dart:core';
import './models/user.dart';
import './src/internal/config.dart';
''',
      [lint(49, 36)],
    );
  }
}
