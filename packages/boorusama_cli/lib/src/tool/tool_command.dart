final class ToolCommand {
  const ToolCommand(this.executable, [this.prefixArgs = const []]);

  final String executable;
  final List<String> prefixArgs;

  List<String> args(List<String> args) => [...prefixArgs, ...args];

  String get displayName => [executable, ...prefixArgs].join(' ');
}
