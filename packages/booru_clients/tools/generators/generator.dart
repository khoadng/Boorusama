import 'template_manager.dart';

abstract class Generator<T> {
  String generate(T input);
}

abstract class TemplateGenerator<T> implements Generator<T> {
  String get templateName;
  Map<String, dynamic> buildContext(T input);

  @override
  String generate(T input) {
    final template = TemplateManager().loadTemplate(templateName);
    final context = buildContext(input);
    return TemplateManager().render(template, context);
  }
}
