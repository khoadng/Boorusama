import 'template_manager.dart';

/// Abstract base class for code generators
abstract class Generator<T> {
  /// Generate code from the given input
  String generate(T input);
}

/// Template-based generator that uses mustache templates
abstract class TemplateGenerator<T> implements Generator<T> {
  /// Name of the template file to use for generation
  String get templateName;

  /// Build the context object for template rendering
  Map<String, dynamic> buildContext(T input);

  /// Generate code using the template and context
  @override
  String generate(T input) {
    final template = TemplateManager().loadTemplate(templateName);
    final context = buildContext(input);
    return TemplateManager().render(template, context);
  }
}
