import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A lint rule that prevents relative imports referencing "/src/" directories.
/// Encourages importing from barrel files instead.
class NoRelativeSrcImports extends AnalysisRule {
  NoRelativeSrcImports()
    : super(
        name: 'no_relative_src_imports',
        description:
            'Prevents relative imports to /src/ directories, encouraging use of barrel files.',
      );

  static const code = LintCode(
    'no_relative_src_imports',
    'Avoid relative imports that reference "/src/" directories. Import from barrel files instead.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri != null && _isRelativeImport(uri) && uri.contains('/src/')) {
      // Check if current file is excluded
      final currentUnit = context.currentUnit;
      if (currentUnit != null) {
        final filePath = currentUnit.file.path;
        if (!_isFileExcluded(filePath)) {
          rule.reportAtNode(node);
        }
      } else {
        // If currentUnit is null, report anyway
        rule.reportAtNode(node);
      }
    }
  }

  bool _isRelativeImport(String uri) {
    return uri.startsWith('./') || uri.startsWith('../');
  }

  bool _isFileExcluded(String filePath) {
    final excludedPaths = _getExcludedPaths();

    for (final excludedPath in excludedPaths) {
      if (filePath.contains(excludedPath)) {
        return true;
      }
    }

    return false;
  }

  List<String> _getExcludedPaths() {
    // Note: In analysis_server_plugin, rule configuration is not directly available
    // in the same way as custom_lint. For now, we'll use a hardcoded list.
    // If configuration is needed, it would need to be passed through the RuleContext
    // or another mechanism.
    return [
      // Add default excluded paths here if needed
      // Example: 'test/', '.g.dart', etc.
    ];
  }
}
