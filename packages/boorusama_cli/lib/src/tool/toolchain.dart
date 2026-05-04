import 'tool_command.dart';

final class Toolchain {
  const Toolchain({
    required this.flutter,
    required this.dart,
    required this.git,
    required this.zip,
    required this.tar,
    required this.createDmg,
  });

  final ToolCommand flutter;
  final ToolCommand dart;
  final ToolCommand git;
  final ToolCommand zip;
  final ToolCommand tar;
  final ToolCommand createDmg;
}
