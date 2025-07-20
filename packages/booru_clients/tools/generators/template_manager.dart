import 'dart:io';

import 'package:mustache_template/mustache.dart';

class TemplateManager {
  static final _instance = TemplateManager._();
  factory TemplateManager() => _instance;
  TemplateManager._();

  final String _templateDir = 'tools/templates';
  final Map<String, String> _templateCache = {};

  String loadTemplate(String templateName) {
    final path = '$_templateDir/$templateName';
    return _templateCache[path] ??= File(path).readAsStringSync();
  }

  String render(String template, Map<String, dynamic> context) {
    final mustache = Template(template);
    return mustache.renderString(context);
  }
}
