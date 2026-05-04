import '../project/project.dart';
import '../tool/tool_runner.dart';
import 'build_plan.dart';

final class Flutter {
  const Flutter(this._tools);

  final ToolRunner _tools;

  Future<void> build(Project project, BuildPlan plan) async {
    await _tools.flutter([
      'build',
      plan.target.flutterTarget,
      ...plan.flutterArgs,
    ]);
  }
}
