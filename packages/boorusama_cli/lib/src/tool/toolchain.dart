import 'tool_command.dart';

final class Toolchain {
  const Toolchain({
    required this.flutter,
    required this.dart,
    required this.git,
    required this.pod,
    required this.zip,
    required this.tar,
    required this.appImageTool,
    required this.flatpak,
    required this.flatpakBuilder,
    required this.createDmg,
  });

  final ToolCommand flutter;
  final ToolCommand dart;
  final ToolCommand git;
  final ToolCommand pod;
  final ToolCommand zip;
  final ToolCommand tar;
  final ToolCommand appImageTool;
  final ToolCommand flatpak;
  final ToolCommand flatpakBuilder;
  final ToolCommand createDmg;
}
