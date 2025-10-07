# Boorusama Lint - Developer Guide

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Adding a New Lint Rule](#adding-a-new-lint-rule)
- [Testing](#testing)
- [Debugging](#debugging)
- [Common Patterns](#common-patterns)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)

## Overview

This package provides custom static analysis rules for the Boorusama project using the Dart `analysis_server_plugin` package. Unlike the legacy `custom_lint` package, this uses the official Dart SDK plugin architecture.

**Key Differences from custom_lint:**
- Uses `AnalysisRule` instead of `DartLintRule`
- Visitor pattern with `SimpleAstVisitor` instead of registry callbacks
- Different context API for accessing file information
- Integrated directly with Dart Analysis Server (no separate process)

## Architecture

### Package Structure
```
packages/boorusama_lint/
├── lib/
│   ├── main.dart                    # Plugin entry point
│   └── src/
│       └── rules/
│           ├── hello_world_rule.dart          # Example rule
│           └── no_relative_src_imports.dart   # Production rule
├── test/
│   ├── hello_world_rule_test.dart
│   └── no_relative_src_imports_test.dart
├── example/
│   ├── test_plugin.dart             # Manual testing
│   └── analysis_options.yaml        # Example config
└── pubspec.yaml
```

### How It Works

1. **Plugin Registration** (`lib/main.dart`):
   - Exports a top-level `plugin` variable
   - Plugin class extends `Plugin` and implements `register()`
   - Rules are registered in the `register()` method

2. **Rule Definition**:
   - Each rule is a class extending `AnalysisRule`
   - Rules define a `LintCode` with name and message
   - Rules register node processors via `registerNodeProcessors()`

3. **Visitor Pattern**:
   - Each rule creates a `_Visitor` class extending `SimpleAstVisitor<void>`
   - Visitor implements `visit*` methods for specific AST nodes
   - Reports diagnostics via `rule.reportAtNode()`

4. **Integration**:
   - Configured in root `analysis_options.yaml` under `plugins:`
   - Enabled per-rule under `diagnostics:`
   - Loaded automatically by Dart Analysis Server in IDEs

## Adding a New Lint Rule

### Step 1: Create the Rule File

Create `lib/src/rules/your_rule_name.dart`:

```dart
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Brief description of what this rule checks.
///
/// ## Examples
///
/// Bad:
/// ```dart
/// // example of violation
/// ```
///
/// Good:
/// ```dart
/// // example of correct usage
/// ```
class YourRuleName extends AnalysisRule {
  static const LintCode code = LintCode(
    'your_rule_name',
    'Error message shown to users.',
    correctionMessage: 'Optional hint on how to fix.',
  );

  YourRuleName()
      : super(
          name: 'your_rule_name',
          description: 'Short description for documentation.',
        );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);

    // Register for specific AST node types you want to visit
    // See "Common Node Types" section below for options
    registry.addMethodInvocation(this, visitor);
    registry.addImportDirective(this, visitor);
    // ... add more as needed
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Your logic here
    if (_shouldReport(node)) {
      rule.reportAtNode(node);

      // Or report at specific offset:
      // rule.reportAtOffset(node.offset, node.length);

      // Or with custom arguments:
      // rule.reportAtNode(node, arguments: ['value1', 'value2']);
    }
  }

  bool _shouldReport(MethodInvocation node) {
    // Implement your check logic
    return false;
  }
}
```

### Step 2: Register the Rule

Edit `lib/main.dart`:

```dart
import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'src/rules/your_rule_name.dart';  // Add import

final plugin = BoorusamaLintPlugin();

class BoorusamaLintPlugin extends Plugin {
  @override
  String get name => 'boorusama_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(YourRuleName());  // Add registration
    // ... other rules
  }
}
```

### Step 3: Create Tests

Create `test/your_rule_name_test.dart`:

```dart
import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:boorusama_lint/src/rules/your_rule_name.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(YourRuleNameTest);
  });
}

@reflectiveTest
class YourRuleNameTest extends AnalysisRuleTest {
  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(YourRuleName());
    super.setUp();
  }

  @override
  String get analysisRule => 'your_rule_name';

  void test_shouldTriggerLint() async {
    await assertDiagnostics(
      r'''
// Code that should trigger the lint
void badExample() {
  // violation here
}
''',
      [lint(offset, length)],  // Specify offset and length
    );
  }

  void test_shouldNotTriggerLint() async {
    await assertNoDiagnostics(
      r'''
// Code that should NOT trigger the lint
void goodExample() {
  // correct usage
}
''',
    );
  }
}
```

**Finding offset and length:**
1. Run the test and let it fail
2. The error message will show: `To accept the current state, expect: lint(X, Y)`
3. Use those values for offset (X) and length (Y)

### Step 4: Enable in Configuration

Edit root `analysis_options.yaml`:

```yaml
plugins:
  boorusama_lint:
    path: packages/boorusama_lint
    diagnostics:
      your_rule_name: true  # Add this line
```

### Step 5: Test and Format

```bash
cd packages/boorusama_lint

# Format code
dart format .

# Run tests
dart test

# Run specific test
dart test test/your_rule_name_test.dart
```

## Testing

### Test Structure

```dart
void test_descriptiveName() async {
  await assertDiagnostics(
    r'''
code here
''',
    [lint(offset, length)],
  );
}
```

**Key points:**
- Use `r'''` (raw strings) to avoid escape issues
- Test method names use underscores (required by test_reflective_loader)
- Each test should verify one specific scenario
- Use `assertNoDiagnostics()` for negative tests

### Creating Test Files

If your rule checks imports/references to other files:

```dart
void test_withExternalFile() async {
  // Create a test file
  newFile('$testPackageLibPath/models/user.dart', 'class User {}');

  await assertDiagnostics(
    r'''
import './models/user.dart';
void main() {
  User();
}
''',
    [], // or [lint(...)]
  );
}
```

### Multiple Diagnostics

```dart
await assertDiagnostics(
  r'''
code with multiple violations
''',
  [
    lint(10, 5),
    lint(20, 8),
    lint(35, 12),
  ],
);
```

### Handling Analyzer Errors

Your tests might encounter built-in analyzer errors (URI_DOES_NOT_EXIST, etc.). These are separate from your custom lint. If they appear in test output, you have two options:

1. **Ignore them** (if they don't affect your rule logic)
2. **Create real files** (using `newFile()` as shown above)

## Debugging

### Method 1: Print Debugging

Add debug prints to your visitor:

```dart
@override
void visitMethodInvocation(MethodInvocation node) {
  print('Visiting method: ${node.methodName.name}');
  print('At offset: ${node.offset}');

  // Your logic
}
```

**Important:** Prints won't show in `dart analyze` output. You'll see them when:
- Running tests (`dart test`)
- The IDE's analysis server log

### Method 2: Test-Driven Debugging

1. Write a failing test with the code that should trigger your rule
2. Run the test: `dart test test/your_rule_test.dart`
3. Examine the output - it shows the AST structure
4. Add prints in your visitor to see what's happening
5. Iterate until the test passes

### Method 3: Example File

Use `example/test_plugin.dart`:

```dart
// Add code that should trigger your rule
import './src/something.dart';

void main() {
  // Test your rule behavior
}
```

Open this file in your IDE and check the Problems panel for diagnostics.

### Method 4: Analyzer Diagnostics

In VSCode:
1. `Cmd+Shift+P` → "Dart: Open DevTools"
2. Check the "Diagnostics" tab for plugin loading issues

### Common Debugging Issues

**Rule not triggering:**
- Check if rule is registered in `lib/main.dart`
- Check if rule is enabled in `analysis_options.yaml`
- Restart Dart Analysis Server
- Verify visitor is calling the right `visit*` method

**Wrong offset/length in tests:**
- Let the test fail and copy the suggested values from error output
- Remember: offset is character position from start of file (0-indexed)

**Context is null:**
- `context.currentUnit` can be null during registration
- Always check: `if (currentUnit != null)` before accessing `currentUnit.file`

## Common Patterns

### Checking Method Names

```dart
@override
void visitMethodInvocation(MethodInvocation node) {
  if (node.methodName.name == 'print') {
    rule.reportAtNode(node);
  }
}
```

### Checking Import URIs

```dart
@override
void visitImportDirective(ImportDirective node) {
  final uri = node.uri.stringValue;
  if (uri != null && uri.startsWith('./')) {
    rule.reportAtNode(node);
  }
}
```

### Checking Class Names

```dart
@override
void visitClassDeclaration(ClassDeclaration node) {
  final className = node.name.lexeme;
  if (className.startsWith('_')) {
    rule.reportAtNode(node.name);
  }
}
```

### Checking Type

```dart
@override
void visitVariableDeclaration(VariableDeclaration node) {
  final type = node.declaredElement?.type;
  if (type != null && type.isDartCoreString) {
    rule.reportAtNode(node);
  }
}
```

### Accessing File Path

```dart
@override
void visitMethodInvocation(MethodInvocation node) {
  final currentUnit = context.currentUnit;
  if (currentUnit != null) {
    final filePath = currentUnit.file.path;
    if (filePath.contains('/test/')) {
      // Different behavior for test files
      return;
    }
  }

  // Regular logic
}
```

### Checking if in lib/ directory

```dart
void visitSomeNode(SomeNode node) {
  if (context.isInLibDir) {
    // Only enforce in lib/ directory
  }
}
```

### Checking if in test/ directory

```dart
void visitSomeNode(SomeNode node) {
  if (context.isInTestDirectory) {
    // Only enforce in test/ directory
  }
}
```

## API Reference

### AnalysisRule

```dart
class YourRule extends AnalysisRule {
  // Required: Define the lint code
  static const LintCode code = LintCode('name', 'message');

  // Required: Constructor calling super
  YourRule() : super(name: 'name', description: 'desc');

  // Required: Return the diagnostic code
  @override
  LintCode get diagnosticCode => code;

  // Required: Register visitors
  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    // Register visitor
  }
}
```

### RuleContext

Available properties:
```dart
context.currentUnit?.file.path      // File path (String)
context.isInLibDir                  // In lib/ directory (bool)
context.isInTestDirectory           // In test/ directory (bool)
context.package                     // Package info (WorkspacePackage?)
context.libraryElement              // Library element (LibraryElement?)
context.typeProvider                // Type system (TypeProvider)
```

### RuleVisitorRegistry

Common node registrations:
```dart
registry.addImportDirective(this, visitor);
registry.addMethodInvocation(this, visitor);
registry.addClassDeclaration(this, visitor);
registry.addVariableDeclaration(this, visitor);
registry.addFunctionDeclaration(this, visitor);
registry.addConstructorDeclaration(this, visitor);
registry.addFieldDeclaration(this, visitor);
registry.addAssignmentExpression(this, visitor);
registry.addBinaryExpression(this, visitor);
registry.addReturnStatement(this, visitor);
registry.addIfStatement(this, visitor);
registry.addForStatement(this, visitor);
registry.addWhileStatement(this, visitor);
registry.addTryStatement(this, visitor);
registry.addCatchClause(this, visitor);
registry.addThrowExpression(this, visitor);
```

### SimpleAstVisitor

Override methods for nodes you want to check:
```dart
class _Visitor extends SimpleAstVisitor<void> {
  @override
  void visitMethodInvocation(MethodInvocation node) { }

  @override
  void visitImportDirective(ImportDirective node) { }

  @override
  void visitClassDeclaration(ClassDeclaration node) { }

  @override
  void visitVariableDeclaration(VariableDeclaration node) { }

  // ... many more visit* methods available
}
```

### Reporting Diagnostics

```dart
// Report at entire node
rule.reportAtNode(node);

// Report at specific offset/length
rule.reportAtOffset(offset, length);

// Report with message arguments (for {0}, {1} in message)
rule.reportAtNode(node, arguments: ['arg1', 'arg2']);
```

### AST Node Common Properties

```dart
// MethodInvocation
node.methodName.name              // String
node.argumentList                 // ArgumentList
node.target                       // Expression?

// ImportDirective
node.uri.stringValue              // String?

// ClassDeclaration
node.name.lexeme                  // String
node.members                      // List<ClassMember>
node.extendsClause                // ExtendsClause?

// VariableDeclaration
node.name.lexeme                  // String
node.initializer                  // Expression?
node.declaredElement?.type        // DartType?
```

## Troubleshooting

### Plugin Not Loading

**Symptoms:** No custom lint warnings appear in IDE

**Solutions:**
1. Check `analysis_options.yaml` has correct plugin path
2. Check rule is enabled under `diagnostics:`
3. Run `flutter pub get` or `dart pub get`
4. Restart Dart Analysis Server:
   - VSCode: `Cmd+Shift+P` → "Dart: Restart Analysis Server"
   - Android Studio: Tools → Dart → Restart Dart Analysis Server
5. Check for errors in Dart Analysis Server log

### Tests Failing with "URI_DOES_NOT_EXIST"

**Cause:** Tests reference files that don't exist

**Solution:** Create files using `newFile()`:
```dart
newFile('$testPackageLibPath/file.dart', 'content');
```

### Wrong Offset in Tests

**Cause:** Manual calculation of offsets is error-prone

**Solution:**
1. Run test and let it fail
2. Copy suggested offset from error: `lint(X, Y)`
3. Use those values

### Rule Triggers Too Much/Too Little

**Debug:**
1. Add print statements to see what nodes are visited
2. Add print for the condition that should trigger the rule
3. Run tests to see output
4. Adjust logic based on what you see

### Can't Access File Path

**Cause:** `context.currentUnit` is null

**Solution:**
```dart
final currentUnit = context.currentUnit;
if (currentUnit != null) {
  final path = currentUnit.file.path;
  // Use path
} else {
  // Handle null case (usually during registration)
}
```

### Performance Issues

**Cause:** Visiting too many nodes or doing expensive operations

**Solutions:**
1. Only register for node types you actually need
2. Return early if conditions don't match
3. Avoid expensive operations in hot paths
4. Use `context.isInLibDir` to skip non-lib files if appropriate

## Real-World Examples

### Example 1: No Relative Src Imports

See `lib/src/rules/no_relative_src_imports.dart` for a complete example that:
- Checks import URIs
- Uses string matching
- Accesses file path for exclusions
- Reports at the import directive node

### Example 2: Hello World (Print Detection)

See `lib/src/rules/hello_world_rule.dart` for a simple example that:
- Checks method invocations
- Compares method names
- Reports on matching methods

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│ CREATE RULE                                                 │
├─────────────────────────────────────────────────────────────┤
│ 1. Create lib/src/rules/my_rule.dart                       │
│ 2. Extend AnalysisRule                                     │
│ 3. Define LintCode                                         │
│ 4. Implement registerNodeProcessors()                      │
│ 5. Create _Visitor extending SimpleAstVisitor<void>        │
│ 6. Override visit* methods                                 │
│ 7. Call rule.reportAtNode() to report issues               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ REGISTER RULE                                               │
├─────────────────────────────────────────────────────────────┤
│ 1. Import in lib/main.dart                                 │
│ 2. Add registry.registerLintRule(MyRule())                 │
│ 3. Enable in analysis_options.yaml under diagnostics:      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ TEST RULE                                                   │
├─────────────────────────────────────────────────────────────┤
│ 1. Create test/my_rule_test.dart                           │
│ 2. Extend AnalysisRuleTest                                 │
│ 3. Register rule in setUp()                                │
│ 4. Use assertDiagnostics() / assertNoDiagnostics()         │
│ 5. Run: dart test                                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ DEBUG                                                       │
├─────────────────────────────────────────────────────────────┤
│ • Add print() in visitor methods                            │
│ • Run dart test to see output                              │
│ • Check test output for suggested lint() values            │
│ • Use example/test_plugin.dart for manual testing          │
│ • Restart Analysis Server after changes                    │
└─────────────────────────────────────────────────────────────┘
```

## Summary

You now have everything needed to:
- ✅ Create new lint rules from scratch
- ✅ Test rules thoroughly
- ✅ Debug issues when they arise
- ✅ Understand the architecture
- ✅ Use common patterns

For the most up-to-date API details, check:
- Existing rules in `lib/src/rules/`
- Test files in `test/`
- This guide's API Reference section

Happy linting! 🎉
