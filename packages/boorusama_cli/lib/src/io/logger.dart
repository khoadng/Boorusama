import 'dart:io';

final class Logger {
  Logger({this.verbose = false, this.ci = false})
    : _colorsEnabled = _shouldUseColors(ci);

  final bool verbose;
  final bool ci;
  final bool _colorsEnabled;

  void info(String message) => _write('INFO', message);
  void warning(String message) => _write('WARNING', message);
  void error(String message) => _write('ERROR', message);

  void debug(String message) {
    if (verbose || ci) _write('DEBUG', message);
  }

  void _write(String level, String message) {
    if (ci) {
      final command = switch (level) {
        'ERROR' => 'error',
        'WARNING' => 'warning',
        'DEBUG' => 'debug',
        _ => 'notice',
      };
      print('::$command::$message');
      return;
    }

    final prefix = '[$level]';
    final coloredPrefix = _colorsEnabled
        ? '${_color(level)}$prefix$_reset'
        : prefix;
    print('$coloredPrefix $message');
  }

  String _color(String level) {
    return switch (level) {
      'ERROR' => _red,
      'WARNING' => _yellow,
      'DEBUG' => _blue,
      _ => _green,
    };
  }

  static bool _shouldUseColors(bool ci) {
    if (ci) return false;
    if (Platform.environment.containsKey('NO_COLOR')) return false;
    if (Platform.environment['GITHUB_ACTIONS'] == 'true') return false;
    return stdout.hasTerminal;
  }

  static const _red = '[0;31m';
  static const _green = '[0;32m';
  static const _yellow = '[1;33m';
  static const _blue = '[0;34m';
  static const _reset = '[0m';
}
