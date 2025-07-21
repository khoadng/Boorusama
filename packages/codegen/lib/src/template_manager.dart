import 'dart:io';
import 'package:mustache_template/mustache.dart';

/// Manages loading and rendering of mustache templates
class TemplateManager {
  static final _instance = TemplateManager._();

  /// Get the singleton instance
  factory TemplateManager() => _instance;
  TemplateManager._();

  String _templateDir = 'templates';
  final Map<String, String> _templateCache = {};

  /// Configure the template directory path
  void setTemplateDirectory(String path) {
    _templateDir = path;
    _templateCache.clear(); // Clear cache when directory changes
  }

  /// Load a template by name with caching
  String loadTemplate(String templateName) {
    final path = '$_templateDir/$templateName';
    return _templateCache[path] ??= File(path).readAsStringSync();
  }

  /// Load a template from a specific path
  String loadTemplateFromPath(String path) {
    return _templateCache[path] ??= File(path).readAsStringSync();
  }

  /// Render a template with the given context
  String render(String template, Map<String, dynamic> context) {
    final mustache = Template(template);
    return mustache.renderString(context);
  }

  /// Clear the template cache
  void clearCache() {
    _templateCache.clear();
  }
}
